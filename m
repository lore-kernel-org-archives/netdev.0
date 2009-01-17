From: Antoine Kaufmann <toni@famkaufmann.info>
Subject: Re: [Bugme-new] [Bug 12303] New: e1000e 82567LM Tx Unit Hang
Date: Sat, 17 Jan 2009 11:16:18 +0100
Message-ID: <20090117101618.GB31715@thales.produktiv.lan>
References: <20081226130200.1588c23f.akpm@linux-foundation.org>
Reply-To: toni@famkaufmann.info
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, wangbj@lzu.edu.cn
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sv0.famkaufmann.info ([89.163.145.14]:45664 "EHLO
	sv0.famkaufmann.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660AbZAQKWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 05:22:37 -0500
Content-Disposition: inline
In-Reply-To: <20081226130200.1588c23f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran into this problem too with my new thinkpad (not an T400 but a x200
with the same network chip).

> > Latest working kernel version: 2.6.27-git2
> > Earliest failing kernel version: unknown
> > Distribution: gentoo amd64 (~amd64), 2008.0
> > Hardware Environment: Thinkpad T400 with GM45 (ICH9)
> >
>
> An e1000e regression.
Couldn't find a version which worked for me. But as Wang mentioned
setting acpi=off works and after some research in the net i found, that
disabling CONFIG_DMAR works too (the first line of the logs is a dma
error too, iirc). Are you sure that you used the same value for
CONFIG_DMAR in your tests, Wang?

I'm willing to do some debugging, but I don't really know where to
start if it's no regression (so bisecting won't work)...

Regards,
-- 
Antoine Kaufmann
<toni@famkaufmann.info>
