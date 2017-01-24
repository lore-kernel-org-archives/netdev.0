From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 0/5] bridge: per vlan lwt and dst_metadata
 support
Date: Mon, 23 Jan 2017 16:09:49 -0800
Message-ID: <58869B4D.9080007@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com> <20170123080805.GB1831@nanopsycho.orion> <20170123095130.59ddcf34@griffin> <58862BAA.4060001@cumulusnetworks.com> <CAJ3xEMiC5xJ+rex8xMnyuGj5QKj+sYA9A6JjOM0xQaZraFSHig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Thomas Graf <tgraf@suug.ch>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        pravin shelar <pshelar@ovn.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jamal Hadi Salim <hadi@mojatatu.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:35054 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdAXAJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:09:51 -0500
Received: by mail-pg0-f47.google.com with SMTP id 194so49072679pgd.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 16:09:51 -0800 (PST)
In-Reply-To: <CAJ3xEMiC5xJ+rex8xMnyuGj5QKj+sYA9A6JjOM0xQaZraFSHig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17, 9:03 AM, Or Gerlitz wrote:
> On Mon, Jan 23, 2017 at 6:13 PM, Roopa Prabhu <roopa@cumulusnetworks.com>
> wrote:
>
>> Also, the goal is to reduce the number of vxlan devices from say 4k to 1.
>> I don't think replacing it with 8k (egress + ingress) rules is going in the
>> right direction.
>>
> Can't you take advantage of the shared vxlan device configuration
> introduced throughout the LWT work such that you have single device dealing
> with many tunnels? why?
>
I tried to cover this in my initial paragraph in the cover letter:
"lwt and dst_metadata/collect_metadata have enabled vxlan l3 deployments to use a 'single vxlan
netdev for multiple vnis' eliminating the scalability problem with using a 'single vxlan netdev per vni'.
This series tries to do the same for vxlan netdevs in pure l2 bridged networks. Use-case/deployment and
details are below." there is more in the cover letter on this.

There is no route pointing to the vxlan device here. vxlan device is a bridged port. And it bridges local host ports to remote vxlan tunnels
vlan-to-vxlan.
