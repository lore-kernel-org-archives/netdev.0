From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [CAIF-RFC 0/8-v2] CAIF Protocol Stack
Date: Mon, 12 Oct 2009 02:41:49 -0700 (PDT)
Message-ID: <20091012.024149.61074790.davem@davemloft.net>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org,
	randy.dunlap@oracle.com, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39107
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755554AbZJLJlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 05:41:53 -0400
In-Reply-To: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Fri, 09 Oct 2009 15:39:23 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> This is the second version of the CAIF patch set.
> The patch set is compiled on 386 for 2.6.31.
> All feedback is apreciated.

There is a lot of coding style issues here I'd like you to
address in your next submission.

Comments are formatted in several places like this:

/*
*
*
*/

It should be:

/*
 *
 *
 */

Also often there are tons of extraneous empty lines in the source
files.  Particularly right after the comment at the top of the
source file.  For example include/net/caif/generic/cfcnfg.h
there is the top comment (which needs to be fixed as described
above) and then 8 empty lines before the #ifndef CFCNFG_H_

That's rediculious, just have one empty line there seperating things.

Seriously, you should be able to just scan over your patch and see all
of these oddities.  They jumped right out at me.  Please clean them
up.

Thank you.

