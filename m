From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [1/8]
Date: Thu, 19 Jul 2007 09:38:52 +0100
Message-ID: <20070719083852.GA2936@infradead.org>
References: <469EECFA.1010704@realitydiluted.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44603 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759392AbXGSIiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 04:38:54 -0400
Content-Disposition: inline
In-Reply-To: <469EECFA.1010704@realitydiluted.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 18, 2007 at 11:47:54PM -0500, Steven J. Hill wrote:
> This first patch 642xx #defines to the 'include/linux/mv643xx.h' file.

I don't think register names should change based on ifefs.  Please make
sure both variants can be supported at runtime.  While mips might not
support different controllers in one binary powerpc certainly does.
