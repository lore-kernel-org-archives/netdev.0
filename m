From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN driver.
Date: Tue, 11 Nov 2014 16:37:56 -0800
Message-ID: <CAHA+R7O_kcNU4bQmVjpbR+50g-6DphV2J=MCYvTE4ELqKpKqgw@mail.gmail.com>
References: <1415744984-25802-1-git-send-email-maheshb@google.com>
	<CAHA+R7OZxCLFYetGHONWkL7uzGur=xSc=ASBT4i5EEeS2Xzwog@mail.gmail.com>
	<20141111.181900.1713364166494134373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:54336 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbaKLAh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 19:37:57 -0500
Received: by mail-qg0-f44.google.com with SMTP id q107so8156585qgd.31
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 16:37:56 -0800 (PST)
In-Reply-To: <20141111.181900.1713364166494134373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 3:19 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <cwang@twopensource.com>
> Date: Tue, 11 Nov 2014 15:12:27 -0800
>
>> On Tue, Nov 11, 2014 at 2:29 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>>> This driver is very similar to the macvlan driver except that it
>>> uses L3 on the frame to determine the logical interface while
>>> functioning as packet dispatcher. It inherits L2 of the master
>>> device hence the packets on wire will have the same L2 for all
>>> the packets originating from all virtual devices off of the same
>>> master device.
>>
>> Why do we need this from the beginning?
>> IOW, what problem does this solve while macvlan doesn't?
>
> macvlan has several built-in limitations, which IP VLAN absolutely
> does not have.
>
> Eric Dumazet spoke about this at the networking track at the kernel
> summit in Chicago, maybe he or another person working on this can
> chime in.

Either you need to publish it or document it in this changelog,
otherwise too much information is missing.
