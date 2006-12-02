From: Daniel Drake <dsd@gentoo.org>
Subject: Re: zd1211 ported to Devicescape stack
Date: Sat, 02 Dec 2006 13:55:08 -0500
Message-ID: <4571CC0C.2070309@gentoo.org>
References: <200612020316.50965.flamingice@sourmilk.net> <4571A295.4030700@gentoo.org> <20061202175737.GA5577@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.iad.emailsrvr.com ([207.97.245.121]:27350 "EHLO
	smtp121.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1424332AbWLBTCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 14:02:39 -0500
To: Daniel Drake <dsd@gentoo.org>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Luis Rodriguez <mcgrof@gmail.com>
In-Reply-To: <20061202175737.GA5577@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ulrich Kunitz wrote:
> I intend to track the d80211 stack, care for the forward porting
> and see also a number of things, which should be done for d80211.

OK, sorry for the false assumptions in my last mail.

In that case, I guess we should both switch to developing zd1211rw on 
d80211 primarily. I am still interested in seeing stuff in mainline so I 
will spend time backporting some of the new developments (but nothing 
major).

We should also use this opportunity to switch to developing in kernel 
git trees (as opposed to external kernel module git trees) for the 
d80211 port.

To start with, I would ask you to pull my git tree then John (or 
Michael?) would pull from you. We should start this at the point when 
Michael's port enters wireless-dev.git

What do you think?

> Daniel your hardware crypto patches should certainly be included
> here.

The patch only enables hardware decryption and doesn't work completely. 
Needs more work.

Daniel
