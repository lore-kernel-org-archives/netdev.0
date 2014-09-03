From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 01/13] openvswitch: split flow structures into
 ovs specific and generic ones
Date: Wed, 03 Sep 2014 17:22:28 -0400
Message-ID: <54078694.5040104@mojatatu.com>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>	<1409736300-12303-2-git-send-email-jiri@resnulli.us> <CALnjE+pscRmfhaWgkWCunJfjvG04RiNUAj6nefSFHrknQTC+xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	andy@greyhouse.net, Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	john.r.fastabend@intel.com, Eric Dumazet <edumazet@google.com>,
	sfeldma@cumulusnetworks.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, John Linville <linville@tuxdriver.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>, jasowang@redhat.com,
	ebiederm@xmission.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.co
To: Pravin Shelar <pshelar@nicira.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:64986 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756751AbaICVWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 17:22:32 -0400
Received: by mail-ie0-f169.google.com with SMTP id tr6so10524887ieb.14
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 14:22:32 -0700 (PDT)
In-Reply-To: <CALnjE+pscRmfhaWgkWCunJfjvG04RiNUAj6nefSFHrknQTC+xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/14 14:41, Pravin Shelar wrote:
> On Wed, Sep 3, 2014 at 2:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:

> HW offload API should be separate from OVS module.

The above part i agree with. Infact it is very odd that it seems
hard to get this point across ;->

> This has following
> advantages.
> 1. It can be managed by OVS userspace vswitchd process which has much
> better context to setup hardware flow table. Once we add capabilities
> for swdev, it is much more easier for vswitchd process to choose
> correct (hw or sw) flow table for given flow.

This i disagree with.
The desire is to have existing user tools to work with offloads.
When necessary, we then create new tools.
Existing tools may need to be taught to do selectively do
hardware vs software offload. We have a precedence with
bridging code which selectively offloads to hardware using iproute2.

> 2. Other application that wants to use HW offload does not have
> dependency on OVS kernel module.

Or on OF for that matter.

> 3. Hardware and software datapath remains separate, these two
> components has no dependency on each other, both can be developed
> independent of each other.
>

The basic definition of "offload" implies dependency;-> So,
I strongly disagree. You may need to go backwards and look at
views expressed on this (other than emails - theres slideware).

cheers,
jamal
