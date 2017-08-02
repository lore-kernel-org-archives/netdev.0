From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH RFC, iproute2] tc/mirred: Extend the mirred/redirect
 action to accept additional traffic class parameter
Date: Wed, 2 Aug 2017 11:41:57 -0700
Message-ID: <CAJieiUi=W1jJBkMXTnFYL=Cw4ZWCv5zeg1vtveW5TyfJ2noe9w@mail.gmail.com>
References: <150154805003.4819.12498976860683140342.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        kiran.patil@intel.com,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        mitch.a.williams@intel.com,
        Alexander Duyck <alexander.duyck@gmail.com>,
        neerav.parikh@intel.com, carolyn.wyborny@intel.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:33249 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752129AbdHBSl7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 14:41:59 -0400
Received: by mail-ua0-f181.google.com with SMTP id 80so24681419uas.0
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 11:41:58 -0700 (PDT)
In-Reply-To: <150154805003.4819.12498976860683140342.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 5:40 PM, Amritha Nambiar
<amritha.nambiar@intel.com> wrote:
> The Mirred/redirect action is extended to accept a traffic
> class on the device in addition to the device's ifindex.
>
> Usage: mirred <DIRECTION> <ACTION> <dev DEVICENAME> <tc TC_INDEX>
>
> Example:
> # tc qdisc add dev eth0 ingress
>
> # tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
>   dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
>   indev eth0 action mirred ingress redirect dev eth0 tc 1


Can we call the new parameter tclass or something else ?.
with this 'tc' appears twice in the command :)
