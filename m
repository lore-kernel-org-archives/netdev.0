From: Pavel Roskin <proski@gnu.org>
Subject: Re: d80211: a patch for standalone d80211 tarball
Date: Mon, 29 Jan 2007 15:23:07 -0500
Message-ID: <1170102187.12657.9.camel@dv>
References: <20070129174812.7D1E94849E@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:37390 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbXA2UXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 15:23:10 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1HBd12-0007WK-2j
	for netdev@vger.kernel.org; Mon, 29 Jan 2007 15:22:12 -0500
In-Reply-To: <20070129174812.7D1E94849E@silver.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Jiri!

On Mon, 2007-01-29 at 18:48 +0100, Jiri Benc wrote:

> +#define register_invisible_netdevice	register_netdevice
> +#define unregister_invisible_netdevice	unregister_netdevice

Please use macros with arguments whenever possible.  This way, incorrect
macro invocations would be detected even if the original prototype is
missing.  Also, the macro name could be used without arguments for other
purposes (variable, gcc attribute etc).

Both cases are highly unlikely for the above macros, but please keep in
mind that some aspiring programmers view the kernel as an example of
good programming style.

-- 
Regards,
Pavel Roskin


