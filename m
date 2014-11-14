From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH Iproute2 next] ip link: Add ipvlan support to the
 iproute2/ip util
Date: Fri, 14 Nov 2014 13:25:32 -0800
Message-ID: <CAF2d9jhGrGxr4YmH3vOXHV_xQpu+_JyRfbDmDVFiLsp5LV5wYg@mail.gmail.com>
References: <1415948212-28927-1-git-send-email-maheshb@google.com> <20141114100959.GA19965@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:50778 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161796AbaKNVZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 16:25:53 -0500
Received: by mail-vc0-f174.google.com with SMTP id la4so5492981vcb.33
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 13:25:52 -0800 (PST)
In-Reply-To: <20141114100959.GA19965@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2014 at 2:09 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
> On Thu, Nov 13, 2014 at 10:56:51PM -0800, Mahesh Bandewar wrote:
>> Adding basic support to create virtual devices using 'ip'
>> utility. Following is the syntax -
>>
>>       ip link add link <master> <virtual> mode [ l2 | l3 ]
>>       e.g. ip link add link eth0 ipvl0 mode l3
>
> I suppose "type ipvlan" is missing on both lines.
>
yes it does, damn!

> Michal Kubecek
>
