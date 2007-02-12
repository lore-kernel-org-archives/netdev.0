From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH 1/1] NetXen: Fix to get the driver working after sparse changes
Date: Mon, 12 Feb 2007 22:40:58 +0000
Message-ID: <20070212224058.GE4095@ftp.linux.org.uk>
References: <200702121233.l1CCXcZ7024013@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: "Amit S. Kale" <amitkale@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43475 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030216AbXBLWlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 17:41:01 -0500
Content-Disposition: inline
In-Reply-To: <200702121233.l1CCXcZ7024013@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 12, 2007 at 04:33:38AM -0800, Amit S. Kale wrote:
> Signed-off-by: Amit S. Kale <amitkale@netxen.com>

ACK.  My apologies - that pile of brainos had been introduced when
I'd been fixing the set_bit() abuses in there (a bunch of places
had been casting address of u32 to unsigned long * and then using
set_bit() to modify it).  FWIW, it had nothing to do with sparse -
just enough RTFS to spot the original bug and not enough of
RTFPatch to spot the introduced breakage.  Sorry.

