From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] Netpoll support for Sibyte MAC
Date: Tue, 20 Mar 2007 13:38:37 +0000
Message-ID: <20070320133837.GA7519@linux-mips.org>
References: <20070319224311.GA10176@plexity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, linux-mips@linux-mips.org,
	Manish Lachwani <mlachwani@mvista.com>
To: Deepak Saxena <dsaxena@plexity.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:38433 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934081AbXCTVh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 17:37:29 -0400
Received: from localhost.localdomain ([127.0.0.1]:41878 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20022976AbXCTVh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 21:37:29 +0000
Content-Disposition: inline
In-Reply-To: <20070319224311.GA10176@plexity.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 19, 2007 at 03:43:11PM -0700, Deepak Saxena wrote:

> +#ifdef CONFIG_SBMAC_COALESCE

Not your patch's fault but ...  CONFIG_SBMAC_COALESCE is being defined
in sb1250-mac.c but the CONFIG_* namespace is reserved for kconfig.

  Ralf
