From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/3] net: propagate dynamic needed_headroom/tailroom changes
Date: Tue, 20 Aug 2013 15:24:37 +0100
Message-ID: <CAGVrzcZQ79rVcezAM7rk6dMBnHySCn3b5wL98npOx=LM=Tb6Mw@mail.gmail.com>
References: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com> <20130820132950.GA1593@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, amwang@redhat.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	kaber@trash.net, David Miller <davem@davemloft.net>,
	vyasevic@redhat.com, Johannes Berg <johannes@sipsolutions.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:51654 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146Ab3HTOZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 10:25:18 -0400
Received: by mail-pd0-f175.google.com with SMTP id q10so444789pdj.34
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 07:25:17 -0700 (PDT)
In-Reply-To: <20130820132950.GA1593@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/8/20 Jiri Pirko <jiri@resnulli.us>:
> Tue, Aug 20, 2013 at 02:45:49PM CEST, f.fainelli@gmail.com wrote:
>>Hi all,
>>
>>This patchset aims at allowing dynamically changing a given device
>>needed_headroom/tailroom space and propagating such events to stacked
>>devices such as bridges and vlans.
>
> You should also add support for other stacked devices, like bonding,
> team, macvlan, ovs-datapath, etc.

Ok, will take a look at these.

>
>>
>>Unless callers use the new helpers (dev_set_headroom/dev_set_tailroom)
>>there is no functional change introduced.
>>
>>I tested this with an out of tree Ethernet driver with both VLANs and
>>bridges and the need for a 64-byte headroom to insert a transmit
>>status descriptor in front of a SKB.
>
> Would be nice to add at least one driver which would use your new api.

cxgb, niu, ps3_gelic_net and gianfar could probably directly benefit
from this change.

Thanks for your feedback!
--
Florian
