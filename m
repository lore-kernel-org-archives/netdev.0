From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH wireless-dev] d80211: Make MACSTR/MAC2STR macro available to drivers
Date: Sun, 23 Jul 2006 11:10:06 +0200
Message-ID: <200607231110.06834.mb@bu3sch.de>
References: <200607230143.31375.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:58071
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751021AbWGWJLM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 05:11:12 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200607230143.31375.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 23 July 2006 10:43, Michael Wu wrote:
> d80211: Make MACSTR/MAC2STR macro available to drivers
> 
> This patch moves the MACSTR/MAC2STR macros to d80211.h
> so that they are available to drivers. It also converts the adm8211
> and bcm43xx drivers to use this macro.

I'd say d80211.h is still the wrong place for this.
What about etherdevice.h?

-- 
Greetings Michael.
