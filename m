From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Silence privacy extensions initialization
Date: Tue, 18 Jan 2011 16:14:12 -0800 (PST)
Message-ID: <20110118.161412.179948581.davem@davemloft.net>
References: <87sjwr4djd.fsf@elegiac.orebokech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: romain@orebokech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34789
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751739Ab1ASANj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 19:13:39 -0500
In-Reply-To: <87sjwr4djd.fsf@elegiac.orebokech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Romain Francoise <romain@orebokech.com>
Date: Mon, 17 Jan 2011 18:59:18 +0100

> When a network namespace is created (via CLONE_NEWNET), the loopback
> interface is automatically added to the new namespace, triggering a
> printk in ipv6_add_dev() if CONFIG_IPV6_PRIVACY is set.
> 
> This is problematic for applications which use CLONE_NEWNET as
> part of a sandbox, like Chromium's suid sandbox or recent versions of
> vsftpd. On a busy machine, it can lead to thousands of useless
> "lo: Disabled Privacy Extensions" messages appearing in dmesg.
> 
> It's easy enough to check the status of privacy extensions via the
> use_tempaddr sysctl, so just removing the printk seems like the most
> sensible solution.
> 
> Signed-off-by: Romain Francoise <romain@orebokech.com>

Yes, this message always bugged me too, applied thanks!
