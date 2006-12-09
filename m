From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please make CONFIG_CFG80211 harder to enable
Date: Sat, 9 Dec 2006 11:06:46 -0500
Message-ID: <20061209160640.GA3365@tuxdriver.com>
References: <1165654123.2816.29.camel@portland.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4208 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756305AbWLIVLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Dec 2006 16:11:33 -0500
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1165654123.2816.29.camel@portland.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 09, 2006 at 03:48:43AM -0500, Pavel Roskin wrote:
> Hello!
> 
> Somebody please mark CONFIG_CFG80211 in wireless-dev.git as
> experimental/broken/incomplete/whatever.  Not only doesn't it work, but
> it also breaks Wireless Extensions if enabled, even if CONFIG_D80211 is
> disabled.
> 
> Driver developers should know that if they enable CONFIG_CFG80211 they
> won't be able to debug their drivers effectifely; they'll have to fix
> cfg80211 first.

Perhaps you could be more specific?  I'm sending this to you from a
box booted on the current (~1 week old) wireless-dev kernel using a
WEXT-configured ipw2200 device.

What problems are you experiencing?  CFG80211 shouldn't interfere w/
WEXT if a driver doesn't support it.

John
-- 
John W. Linville
linville@tuxdriver.com
