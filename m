From: David Lamparter <equinox@diac24.net>
Subject: Re: IEEE 802.1ag / 802.1x / Y1731
Date: Fri, 1 Jul 2011 14:25:37 +0200
Message-ID: <20110701122536.GB2613105@jupiter.n2.diac24.net>
References: <BANLkTingLv9XxLqU7nQSct8wqhyvkq=LqA@mail.gmail.com>
 <BANLkTimHM0ydiD5eEc2hzk+AQ1WBQQB97g@mail.gmail.com>
 <BANLkTim1VwXRiWdO6PWN6coDeOswQqSOXA@mail.gmail.com>
 <BANLkTino1iUe3r3dmA5DraBZo6bYSSQ7Kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Balaji G <balajig.foss@gmail.com>, netdev@vger.kernel.org
To: "Satendra..." <satendra.pratap@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:55178 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756256Ab1GAMZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 08:25:42 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTino1iUe3r3dmA5DraBZo6bYSSQ7Kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2011 at 05:42:41PM +0530, Satendra... wrote:
> You mean CFM OAM 802.1ag can not be supported under linux yet.
> I mean there are many routers which are running linux and if they want
> to support CFM OAM on
> their routers they will have to make changes in Linux networking stack?
> Could you please tell about the support of Y.1731 / 802.1ah / 802.1x
> in the linux networking
> stack ?

Hi,


i'm working on a part of the 802.1ah standard, namely the mac-in-mac
encapsulation. I'll see if i can push it out soon.

Note that that only gets you a quarter of the job done since you need
PBB bridge behaviour as well, which is somewhat more complex to do than
the encapsulation. It will probably require some extensions to the
kernel<>userspace STP interface.

802.1X is supported by hostapd. (http://hostap.epitest.fi) with the
"wired" driver. There's nothing needed from kernel side for this.

802.1ag you can maybe implement in userspace, i don't know the spec to
tell.


-David

