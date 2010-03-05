From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] device.h drivers/base/core.c Convert dev_<level>
 macros to functions
Date: Thu, 4 Mar 2010 16:56:09 -0800
Message-ID: <20100304165609.20849b93.akpm@linux-foundation.org>
References: <cover.1267682641.git.joe@perches.com>
	<f2b24d484347c083fa87856a75c1d96102af9005.1267682641.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52688 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754189Ab0CEA4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 19:56:20 -0500
In-Reply-To: <f2b24d484347c083fa87856a75c1d96102af9005.1267682641.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 Mar 2010 22:27:23 -0800 Joe Perches <joe@perches.com> wrote:

> Save ~60k in a defconfig
> 
> Use %pV and struct va_format
> Format arguments are verified before printk

Well that doesn't work very well.

drivers/net/pcmcia/pcnet_cs.c:117: error: 'dev_info' redeclared as different kind of symbol
include/linux/device.h:645: error: previous declaration of 'dev_info' was here

there are lots of other dev_info's which will fail plus perhaps
dev_err's, etc.

