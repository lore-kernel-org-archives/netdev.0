From: Grant Grundler <grundler@chromium.org>
Subject: Re: asix, setting MAC broken in v3.2. Bisected to "NET: fix phy init
 for AX88772 USB ethernet".
Date: Mon, 9 Jan 2012 09:21:43 -0800
Message-ID: <CANEJEGsUOzpb_Cg0DfDX8ftMZr9fhAMGc7ba9yJCKkQ6Vvhe+w@mail.gmail.com>
References: <20120106131051.92814bd4b7x0nmqs@www.81.fi>
	<CANEJEGvXST4YzDL4kuF=kjZBN=ng-bC5UptCU2zk6JUmhpVjmg@mail.gmail.com>
	<20120108171802.287811bpiixnymys@www.81.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Freddy Xin <freddy@asix.com.tw>,
	Olof Johansson <olofj@chromium.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Hollis <dhollis@davehollis.com>,
	Allan Chou <allan@asix.com.tw>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:38565 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932266Ab2AIRVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 12:21:44 -0500
Received: by ggdk6 with SMTP id k6so1667312ggd.19
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2012 09:21:43 -0800 (PST)
In-Reply-To: <20120108171802.287811bpiixnymys@www.81.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 8, 2012 at 7:18 AM, Jussi Kivilinna
<jussi.kivilinna@mbnet.fi> wrote:
...
> It's Wii Ethernet adapter,
> Bus 001 Device 008: ID 0b95:7720 ASIX Electronics Corp. AX88772

...
> Both attached.

[lsusb/dmesg  output]  Thanks!

...
> I found out that setting MAC in ax88722_reset() solves the issue for me.
> Maybe changes to init/reset sequence causes hardware to be reseted after
> set_mac_address call and revert to default MAC?

That's exactly what I was thinking too over the weekend.


> Patch attached.

I'll try the patch here to confirm. Thanks!

cheers,
grant
