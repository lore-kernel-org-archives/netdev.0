From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] lib/vsprintf.c: Add %pMF to format FDDI bit reversed
 MAC addresses
Date: Tue, 19 Jan 2010 02:57:34 -0800
Message-ID: <20100119025734.ce74ae5b.akpm@linux-foundation.org>
References: <BD79186B4FD85F4B8E60E381CAEE19090208954A@mi8nycmail19.Mi8.com>
	<1262888625.10429.23.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: H Hartley Sweeten <hartleys@visionengravers.com>,
	David Miller <davem@davemloft.net>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52243 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752141Ab0ASLAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 06:00:10 -0500
In-Reply-To: <1262888625.10429.23.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Jan 2010 10:23:45 -0800 Joe Perches <joe@perches.com> wrote:

> Adds 56 bytes to object size

You might want to consider making some of the net-specific code in
vsprintf.c go away if CONFIG_NET=n.

