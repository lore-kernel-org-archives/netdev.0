From: Jiri Benc <jbenc@suse.cz>
Subject: Re: move zd1201 where it belongs
Date: Mon, 5 Jun 2006 16:44:11 +0200
Message-ID: <20060605164411.42d8dc40@griffin.suse.cz>
References: <20060605103952.GA1670@elf.ucw.cz>
	<1149506120.3111.52.camel@laptopd505.fenrus.org>
	<20060605113332.GB2132@elf.ucw.cz>
	<20060605141322.GB23350@tuxdriver.com>
	<20060605142912.GF2132@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, pe1rxq@amsat.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57312 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751159AbWFEOoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 10:44:13 -0400
To: Pavel Machek <pavel@suse.cz>
In-Reply-To: <20060605142912.GF2132@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Jun 2006 16:29:12 +0200, Pavel Machek wrote:
> Yes, because this should go in as a git patch (so it is move, not
> create new file), and I was hoping for Jiri to generate proper
> git-patch :-).

The proper person for this is maintainer of wireless or USB.

> Here it is, still
> 
> Signed-off-by: Pavel Machek <pavel@suse.cz>

In addition to this,
mv drivers/usb/net/zd1201.[ch] drivers/net/wireless/
needs to be invoked.

I agree that the patch should be applied to remove confusion (not many
people know about this driver, even among wireless developers).

 Jiri

-- 
Jiri Benc
SUSE Labs
