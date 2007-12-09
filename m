From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Bogus commit 70eba18b ("make bnx2x select ZLIB_INFLATE")?
Date: Sat, 08 Dec 2007 23:48:48 -0500
Message-ID: <475B73B0.2090006@garzik.org>
References: <adasl2ca7md.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org,
	Eliezer Tamir <eliezert@broadcom.com>,
	Lee Schermerhorn <lee.schermerhorn@hp.com>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47942 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbXLIEsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2007 23:48:51 -0500
In-Reply-To: <adasl2ca7md.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> Commit 70eba18b ("make bnx2x select ZLIB_INFLATE") in Linus's tree
> seems bogus.  As far as I can tell, bnx2x is not upstream yet, and the
> commit in question actually adds "select ZLIB_INFLATE" to the TEHUTI
> config, since there is no BNX2X config option (and also I don't see
> any reference to zlib in any tehuti files).
> 
> I assume this is some sort of merge problem that got added to the
> wrong tree and should be reverted upstream.

Yeah DaveM pointed that too.  My fault (and yes it should be reverted 
upstream...  I've prepared a commit for my next round of submissions)

	Jeff



