From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH -mm] ne2: needs more 8390 support functions
Date: Wed, 12 Mar 2008 12:44:12 +0000
Message-ID: <20080312124412.6089948c@the-village.bc.nu>
References: <20080311095643.01cd3708.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, jgarzik <jgarzik@pobox.com>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zux006-051-205.adsl.green.ch ([81.6.51.205]:11893 "EHLO
	the-village.bc.nu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751480AbYCMKZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 06:25:06 -0400
In-Reply-To: <20080311095643.01cd3708.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Mar 2008 09:56:43 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> ne2 (MCA) needs both 8390.o and 8390p.o functions:

NAK - the two modules are alternatives nothing should use both - is 8390p
not sufficient ?
