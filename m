From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gigaset: silence GCC warning for unused 'format_ie'
Date: Mon, 16 Jul 2012 23:24:48 -0700 (PDT)
Message-ID: <20120716.232448.2148675554738101630.davem@davemloft.net>
References: <1342343515.1780.2.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tilman@imap.cc, hjlipp@web.de, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109Ab2GQGYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:24:51 -0400
In-Reply-To: <1342343515.1780.2.camel@x61.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>
Date: Sun, 15 Jul 2012 11:11:55 +0200

> Building Gigaset's CAPI support without Gigaset's debugging enabled
> triggers this GCC warning:
>     'format_ie' defined but not used [-Wunused-function]
> 
> Silence this warning by wrapping format_ie() in an "#ifdef
> CONFIG_GIGASET_DEBUG" and "#endif" pair.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

Applied.
