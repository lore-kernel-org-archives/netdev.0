From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/2] d80211: Turn PHYmode list from an array into a linked list
Date: Sat, 1 Jan 2000 01:23:26 +0100
Message-ID: <200001010123.27251.mb@bu3sch.de>
References: <200612141920.11439.mb@bu3sch.de> <200612160140.16446.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: jbenc@suse.cz, linville@tuxdriver.com, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39314
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161036AbWLPPN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Dec 2006 10:13:58 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200612160140.16446.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 16 December 2006 07:40, Michael Wu wrote:
> On Thursday 14 December 2006 13:20, Michael Buesch wrote:
> > -int ieee80211_update_hw(struct ieee80211_hw *hw)
> > +int ieee80211_register_hwmode(struct ieee80211_hw *hw,
> > +			      struct ieee80211_hw_mode *mode)
> Looks like this function never returns nonzero now. Can it return void 
> instead? This would simplify the fixes for drivers a bit.

Well, theoretically, yes.
Maybe it's only my personal way to do things, but I usually
let such API register functions return an error code, because
if we internally change it only slightly, it often turns out
we need an error code. For example let's say we need to
kmalloc something in that function for some reason.

If you say, well, breaking the API again is ok, when this is required,
send a patch. ;)

-- 
Greetings Michael.
