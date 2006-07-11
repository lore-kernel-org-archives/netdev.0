From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [patch] do not allow IPW_2100=Y or IPW_2200=Y
Date: Tue, 11 Jul 2006 12:53:19 +0100
Message-ID: <44B3912F.3010300@gentoo.org>
References: <20060710152032.GA8540@elf.ucw.cz> <44B2940A.2080102@pobox.com> <200607102305.06572.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Pavel Machek <pavel@ucw.cz>,
	yi.zhu@intel.com, jketreno@linux.intel.com,
	Netdev list <netdev@vger.kernel.org>, linville@tuxdriver.com,
	kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:120 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1750859AbWGKLrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 07:47:42 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607102305.06572.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Does the ipw driver _really_ need the firmware on insmod time?
> bcm43xx, for example, loads the firmware on "ifconfig up" time.
> If ipw really needs the firmware on insmod, is it possible to
> defer it to later at "ifconfig up" time?

Is bcm43xx able to get the MAC address before the firmware is loaded?
Last time I checked, if the MAC address is only discovered after the 
interface is created (as would be the case with ipw loading firmware on 
ifconfig up, I think), interface renaming does not work.

Daniel
