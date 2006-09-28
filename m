From: Daniel Drake <dsd@gentoo.org>
Subject: Re: softmac mtu
Date: Thu, 28 Sep 2006 13:02:15 -0400
Message-ID: <451C0017.8010104@gentoo.org>
References: <ef3s4u$or5$3@sea.gmane.org> <ef9a0b$4jb$4@sea.gmane.org> <20060925200125.GF16949@tuxdriver.com> <20060927143905.721ddf3e@griffin.suse.cz> <1159365434.451a833ae7728@imp3-g19.free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.iad.emailsrvr.com ([207.97.245.111]:21733 "EHLO
	smtp111.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1750882AbWI1RCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 13:02:11 -0400
To: castet.matthieu@free.fr
In-Reply-To: <1159365434.451a833ae7728@imp3-g19.free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

castet.matthieu@free.fr wrote:
> I have a patch for 802.11 linux stack.
> It works for mtu like 2000 but if the packet is fragmented (with mtu = 3000 for
> example) my usb dongle (zd1211) crash (doesn't work anymore until I replug it).
> I need to investigate a bit.

zd1211rw requires explicit support for large frames due to the USB 
protocol in use. This is supported by the vendor driver but not zd1211rw 
just yet.

Daniel

