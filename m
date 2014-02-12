From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Wed, 12 Feb 2014 10:47:15 +0100
Message-ID: <52FB4323.7020608@6wind.com>
References: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>	 <20140211014535.GA11150@order.stressinduktion.org>	 <CAHA+R7N2rxt5vyF+i8mi04dJaLk5bCgMAZOCexOLULLcQ-mT6w@mail.gmail.com>	 <20140211024009.GD11150@order.stressinduktion.org> <1392092120.6615.64.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:42330 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaBLJrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 04:47:19 -0500
Received: by mail-ee0-f43.google.com with SMTP id c41so4165648eek.2
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 01:47:18 -0800 (PST)
In-Reply-To: <1392092120.6615.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/02/2014 05:15, Eric Dumazet a =C3=A9crit :
> On Tue, 2014-02-11 at 03:40 +0100, Hannes Frederic Sowa wrote:
>
>> Setting up a macvlan and moving it into another namespace without mo=
ving
>> the parent device is a nice feature. I am not an administrator, so I=
 don't
>> use that stuff often, but given you can easily spawn namespaces and =
put
>> applications into them, one of the easiest things to connect those t=
o
>> local network without routing over veth and such is the macvlan inte=
rface.
>
> Exactly.

I also agree.
