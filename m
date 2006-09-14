From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: ieee80211 and devices which decrypt in hardware
Date: Thu, 14 Sep 2006 09:51:28 +0200
Message-ID: <1158220288.2936.16.camel@ux156>
References: <45077241.1070102@gentoo.org> <200609131627.58153.mb@bu3sch.de>
	 <450887B9.7080308@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	yi.zhu@intel.com, ipw2100-admin@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:20366 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751444AbWINHuy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 03:50:54 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <450887B9.7080308@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-13 at 18:35 -0400, Daniel Drake wrote:
 
> +       /* If the device does decryption but leaves the IV in place then we: 
> +        * need to kill it. */: 
> +       if (!can_be_decrypted && (fc & IEEE80211_FCTL_PROTECTED)): 
> +               hdrlen += 4;: 

That might work, unless there are devices that leave the protected bit
set but do strip the IV/ICV...

johannes
