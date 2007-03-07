From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: [PATCH 1/2] pcnet32: only allocate init_block dma consistent
Date: Tue, 6 Mar 2007 19:39:21 -0800
Message-ID: <f2b55d220703061939w731dfcc4t8e0ddcf238203bd@mail.gmail.com>
References: <20070306184523.GA23268@verizon.net>
	 <20070307031011.GA4281@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Don Fry" <pcnet32@verizon.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: "Ralf Baechle" <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:28443 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030494AbXCGDjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 22:39:23 -0500
Received: by wr-out-0506.google.com with SMTP id 58so44192wri
        for <netdev@vger.kernel.org>; Tue, 06 Mar 2007 19:39:22 -0800 (PST)
In-Reply-To: <20070307031011.GA4281@linux-mips.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/6/07, Ralf Baechle <ralf@linux-mips.org> wrote:
> This small change btw. delivers about ~ 3% extra performance on a very
> slow test system.

Has this change been tested / benchmarked under VMWare?  pcnet32 is
the (default?) virtual device presented by VMWare Workstation, and
that's probably a large fraction of its use in the field these days.
But then Don probably already knows that.  :-)

Cheers,
- Michael
