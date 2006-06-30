From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH 9/15] pcmcia: hostap_cs.c - 0xc00f, 0x0000 conflicts
	with pcnet_cs
Date: Fri, 30 Jun 2006 17:18:43 -0400
Message-ID: <1151702323.21767.3.camel@dv>
References: <20060630195107.GA9095@dominikbrodowski.de>
	 <20060630195217.GB9095@dominikbrodowski.de>
	 <20060630195255.GC9095@dominikbrodowski.de>
	 <20060630195358.GD9095@dominikbrodowski.de>
	 <20060630195439.GE9095@dominikbrodowski.de>
	 <20060630195501.GF9095@dominikbrodowski.de>
	 <20060630195600.GG9095@dominikbrodowski.de>
	 <20060630195657.GH9095@dominikbrodowski.de>
	 <20060630195753.GI9095@dominikbrodowski.de>
	 <20060630195920.GJ9095@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org,
	jkmaline@cc.hut.fi, hostap@shmoo.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:39361 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S932611AbWF3VTI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 17:19:08 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FwQOJ-0003qv-Tm
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 17:19:08 -0400
To: Dominik Brodowski <linux@dominikbrodowski.net>
In-Reply-To: <20060630195920.GJ9095@dominikbrodowski.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dominik,

On Fri, 2006-06-30 at 21:59 +0200, Dominik Brodowski wrote:
> -	PCMCIA_DEVICE_MANF_CARD(0xc00f, 0x0000),
> +/*	PCMCIA_DEVICE_MANF_CARD(0xc00f, 0x0000),    conflict with pcnet_cs */

That's fine if we also add symbolic names.  I could identify two
hostap_cs compatible cards using this ID :

card "Allied Telesyn AT-WCL452"
 version "Allied Telesyn", "AT-WCL452 Wireless PCMCIA Radio", "Ver.
1.00"
 manfid 0xc00f, 0x0000
 bind "hostap_cs"

card "corega WL PCCL-11"
 version "corega", "WL PCCL-11", "ISL37300P", "RevA"
 manfid 0xc00f, 0x0000
 bind "hostap_cs"

(from http://www.handhelds.org/hypermail/oe-commits/41/4121.html)

-- 
Regards,
Pavel Roskin

