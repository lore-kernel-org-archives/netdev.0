From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SUNRPC: Mark buffer used for debug printks
	with	__maybe_unused
Date: Wed, 20 Feb 2008 12:00:35 -0500
Message-ID: <1203526835.13125.11.camel@heimdal.trondhjem.org>
References: <47BC3303.2040101@openvz.org>
	 <1203521357.7181.163.camel@localhost> <1203521514.7181.167.camel@localhost>
	 <47BC48C6.3050208@trash.net>  <47BC550D.7040003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Joe Perches <joe@perches.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:45251 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754783AbYBTRAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 12:00:44 -0500
In-Reply-To: <47BC550D.7040003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-02-20 at 19:27 +0300, Pavel Emelyanov wrote:
> Patrick McHardy wrote:
> > Joe Perches wrote:
> >> On Wed, 2008-02-20 at 07:29 -0800, Joe Perches wrote:
> >>   
> >>> fs/nfsd/nfsproc.c:              char buf[RPC_MAX_ADDRBUFLEN];
> >>> Perhaps there should be a DECLARE_RPC_BUF(buf) macro?
> >>> #define DECLARE_RPC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
> >>>     
> >> Make that:
> >>
> >> #define DECLARE_RPC_BUF(var) char var[RPC_MAX_ADDRBUFLEN] __maybe_unuse
> 
> OK, I'll send the patch in a moment.

1) Please always Cc linux-nfs@vger.kernel.org when changing the sunrpc
code

2) Please don't use the name RPC_BUF. These are debugging strings, not
buffers. Something like DECLARE_RPC_DEBUG_STR() would be more
appropriate.

3) If you're going to use a macro, why not just use the existing
RPC_IFDEBUG()?

Trond

