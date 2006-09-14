From: Michael Buesch <mb@bu3sch.de>
Subject: Re: ieee80211 and devices which decrypt in hardware
Date: Thu, 14 Sep 2006 17:25:59 +0200
Message-ID: <200609141725.59284.mb@bu3sch.de>
References: <45077241.1070102@gentoo.org> <200609131627.58153.mb@bu3sch.de> <450887B9.7080308@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yi.zhu@intel.com,
	ipw2100-admin@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:9966
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750775AbWINP1J
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 11:27:09 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <450887B9.7080308@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 14 September 2006 00:35, Daniel Drake wrote:
> Michael Buesch wrote:
> > Does it strip ICV and FCS?
> 
> The driver always strips FCS (unconditionally).
> 
> The device does not strip ICV even when hardware decryption is in use, 
> it gets included at the end of the frame, and I guess we should also 
> handle that.

You should skb_trim it, or otherwise it will be included in the
payload, which will result in various weird bugs.

-- 
Greetings Michael.
