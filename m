From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 v1.7 rx error...
Date: Tue, 26 Sep 2006 21:09:31 +0100
Message-ID: <6278d2220609261309v148618a4p4315d17aedc79a7d@mail.gmail.com>
References: <6278d2220609261058y4b686489p813ef504f71bca4a@mail.gmail.com>
	 <20060926115526.4bb5b99b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:34179 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932262AbWIZUJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 16:09:32 -0400
Received: by wr-out-0506.google.com with SMTP id i7so869608wra
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 13:09:32 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060926115526.4bb5b99b@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The server processor is a Pentium-M 1.7GHz (ondemand governor, from
0.6GHz -> 1.7GHz).

Gigabit path from server -> switch -> client. Client runs WinXP,
Core2Duo 2.13GHz, Realtek RTL8168/8111 PCI-e NIC.

Flow contol enabled in both directions, both for client and server:
sky2 lan0: Link is up at 1000 Mbps, full duplex, flow control both

Jumbo frames are in use on the tx side of server only - MTU 9000. I
reproduced this with sky2 v1.7 with non-jumbo MTU 1500 frames too.

Let me know if there is any further information I can grab and/or any
other settings/tweaks/patches I can try.

Dan

On 26/09/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> On Tue, 26 Sep 2006 18:58:40 +0100
> "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
>
> > I got a this message with sky2 on 2.6.18 + the sky2 v1.7 patches - it
> > has different status bits set than before (0x977d977d):
> >
> > kernel: sky2 lan0: rx error, status 0x377d377d length 0
> >
> > Great work so far though - this race takes a while to hit!
> >
> > Dan
>
> What speed processor? Are you using receive flow control? Are you
> using Jumbo frames?
>
> --
> Stephen Hemminger <shemminger@osdl.org>
-- 
Daniel J Blueman
