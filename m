From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 1/2] pcnet32: only allocate init_block dma consistent
Date: Wed, 7 Mar 2007 03:10:11 +0000
Message-ID: <20070307031011.GA4281@linux-mips.org>
References: <20070306184523.GA23268@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:33900 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030778AbXCGDM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 22:12:59 -0500
Received: from localhost.localdomain ([127.0.0.1]:217 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021476AbXCGDM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 03:12:56 +0000
Content-Disposition: inline
In-Reply-To: <20070306184523.GA23268@verizon.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 10:45:23AM -0800, Don Fry wrote:

> The patch below moves the init_block out of the private struct and
> only allocates init block with pci_alloc_consistent. 
> 
> This has two effects:
> 
> 1. Performance increase for non cache coherent machines, because the
>    CPU only data in the private struct are now cached

This small change btw. delivers about ~ 3% extra performance on a very
slow test system.

  Ralf
