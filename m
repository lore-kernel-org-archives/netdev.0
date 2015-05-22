From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of netns
Date: Fri, 22 May 2015 14:29:37 -0700
Message-ID: <CAHA+R7O7sVkA7Ku13gKbwa9HZ0gJZm5kw09Oeiy4u1ZMiv=ijA@mail.gmail.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
	<874mnn9t12.fsf@x220.int.ebiederm.org>
	<555F969B.3090706@ahsoftware.de>
	<CAHA+R7NCjKn86R+OLX+4bkB0kv3WcXGB5NPui+v_X=CKqQtPLA@mail.gmail.com>
	<555F9BC8.1040509@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37469 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161013AbbEVV3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 17:29:38 -0400
Received: by wibt6 with SMTP id t6so428833wib.0
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 14:29:37 -0700 (PDT)
In-Reply-To: <555F9BC8.1040509@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015 at 2:12 PM, Alexander Holler <holler@ahsoftware.de> wrote:
>>
>> Bridge doesn't have an underlying link, so no LINK_NETNSID. LINK_NETNSID
>> is only added when its underlying link is in a different netns.
>
>
> I'm using "link" similiar as interface. Maybe I've no idea what the
> attribute LINK:NETSID really means, but I've understood it as the one
> attribute which indicates the namespace an interface (or link), br0 in my
> example, lives in.
>

It is for an underlying link for example: a veth pair is a link for each other,
a tunnel device has a link to transmit packets.

Bridge and bonding are master devices where "slaves" (or ports for bridge)
can join.

netns doesn't have a name or id by nature, we assign it a name by binding
mount some /proc file, these LINK_NETNSID's are not absolutely unique either,
just relatively.
