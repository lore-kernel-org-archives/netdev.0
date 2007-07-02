From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH UPDATE #2] Extract chip specific code out of lasi_82596.c
Date: Mon, 02 Jul 2007 08:43:04 -0400
Message-ID: <4688F2D8.6020308@pobox.com>
References: <20070627224622.GA13356@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51183 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880AbXGBMnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:43:06 -0400
In-Reply-To: <20070627224622.GA13356@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

applied both patches.

Please provide an update that does at Andrew requested -- rather than 
#include'ing lib82596.c, you should update the Makefile for relevant 
drivers to look like

obj-$(CONFIG_FOO_BAR) += lib82596.o foo_bar_82596.o

and make sure it exports everything to make lib82596 a full fledged module.


