From: Christoph Hellwig <hch@infradead.org>
Subject: Re: nicstat
Date: Sat, 14 Jul 2007 14:43:55 +0100
Message-ID: <20070714134355.GA11022@infradead.org>
References: <Line.LNX.4.64.0707140927290.25256@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>, Tim.Cook@sun.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37469 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757057AbXGNNn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 09:43:58 -0400
Content-Disposition: inline
In-Reply-To: <Line.LNX.4.64.0707140927290.25256@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 14, 2007 at 09:28:50AM -0400, James Morris wrote:
> This might be of interest (there's a Linux version):
> 
> http://blogs.sun.com/timc/entry/nicstat_the_solaris_network_monitoring

The code has a comment:

 * CAVEATS
 *	It appears there is no way to determine the speed of an interface
 *	in Linux, so the %Util numbers are bogus at present.

Which is not true.  This is easily retriviable through ethtool for any
driver supporting it.

Aso I'm a bit surprised that a

"extern int errno;"

still works with a modern libc, folks please always include errno.h instead.
Same for the opt* variables for getopt, please always get them through
unistd.h
