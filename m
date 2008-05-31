From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool -
 e1000/pcnet32
Date: Sat, 31 May 2008 13:11:43 +0100
Message-ID: <20080531131143.516ca56e@core>
References: <482DA5B6.1020606@sngx.net>
	<482DB46A.8020103@cosmosbay.com>
	<482EF192.4070707@sngx.net>
	<482F5113.5090703@cosmosbay.com>
	<482F610D.2080108@sngx.net>
	<20080518003104.GK28241@solarflare.com>
	<482FBA09.80201@sngx.net>
	<483E0AAE.2020107@sngx.net>
	<20080528221118.63da4092.akpm@linux-foundation.org>
	<483EA2D1.8050603@sngx.net>
	<20080529154525.3916c7b5@core>
	<20080530151250.b44a119a.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: James Cammarata <jimi@sngx.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:53841 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751601AbYEaM0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 08:26:13 -0400
In-Reply-To: <20080530151250.b44a119a.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When diagnosing network problems, the ability to zero counters is
> a major aid in diagnosis.  Writing scripts is not a general solution
> since often several systems are involved and it's not simple to do
> this via a script.  Saving stats output and running beforeafter on
> a number of systems is a royal pain when troubleshooting.

Zeroing them is not a general solution either - you break all the other
tools monitoring the same stats in parallel - like network usage monitors.

This is a user space tools problem, scripts or otherwise.

Alan
