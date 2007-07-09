From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: improve interrupt handling
Date: Mon, 9 Jul 2007 17:19:22 -0500
Message-ID: <20070709221922.GP4457@austin.ibm.com>
References: <20070709.174808.-1350520249.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57405 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913AbXGIWTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 18:19:24 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l69MJOAY007837
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 18:19:24 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l69MJOiO346376
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 18:19:24 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l69MJNsL032686
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 18:19:23 -0400
Content-Disposition: inline
In-Reply-To: <20070709.174808.-1350520249.kouish@swc.toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 09, 2007 at 05:48:08PM +0900, Ishizaki Kou wrote:
> We intend this patch to improve spidernet interrupt handling to be
> more strict.  We had following problem and this patch solves it.

Looks reasonable to me. I'll forward it upstream. In the future,
could you use "diff -Nupr"? it adds some extra information
(the name of the subroutine) to the patch chunks; this makes 
it easier to read. 

QUILT_DIFF_OPTS="-Nupr"
in ~/.quiltrc if you use quilt.

--linas

