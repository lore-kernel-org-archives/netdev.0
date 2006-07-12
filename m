From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [patch] do not allow IPW_2100=Y or IPW_2200=Y
Date: Wed, 12 Jul 2006 12:39:58 +0800
Message-ID: <1152679198.3496.99.camel@debian.sh.intel.com>
References: <20060710152032.GA8540@elf.ucw.cz> <44B2940A.2080102@pobox.com>
	 <200607102305.06572.mb@bu3sch.de>  <20060711133227.GA1650@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Jeff Garzik <jgarzik@pobox.com>,
	jketreno@linux.intel.com, Netdev list <netdev@vger.kernel.org>,
	linville@tuxdriver.com, kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60563 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932191AbWGLEky (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 00:40:54 -0400
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20060711133227.GA1650@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-07-11 at 15:32 +0200, Pavel Machek wrote:
> Probably not. This (very dirty) hack implements that (with some level
> of success -- ifconfig down/ifconfig up is enough to get wireless
> working).

You just need to

$ iwpriv ethX reset

Thanks,
-yi
