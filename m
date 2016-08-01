From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: i10e: use matching format indentifiers
Date: Sun, 31 Jul 2016 20:47:59 -0700 (PDT)
Message-ID: <20160731.204759.1283451349474511870.davem@davemloft.net>
References: <1469957968-726-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618AbcHADsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 23:48:14 -0400
In-Reply-To: <1469957968-726-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 11:39:28 +0200

> i is defined as int but output as %u several times.
> Change the definition to unsigned.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

I hate changes like this.

The canonical way to loop over a value is to use a signed integer,
named 'i', and go:

	for (i = 0; i < X; i ++)

'i' can never be negative, therefore we know that this usage
is safe.

I'd rather you convert the "%u" to "%d".

I'm very disappointed in your patches, and it is clear you
are just finding the easiest and simplest way to shut up
compiler warnings you are seeing rather than analyzing the
code you are making changes to in order to determine what
the best and most appropriate fix might be.
