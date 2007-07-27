From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Proposed interface for per-packet mesh-ttl
Date: Fri, 27 Jul 2007 20:56:16 +0100
Message-ID: <20070727195616.GA31510@infradead.org>
References: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com> <445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Javier Cardona <javier@cozybit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:60892 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761231AbXG0T4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 15:56:17 -0400
Content-Disposition: inline
In-Reply-To: <445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 03, 2007 at 12:29:24PM -0700, Javier Cardona wrote:
> I'm currently working on per-packet mesh ttl.  My plan is to register
> new mesh sockopts through netfilter.  The user interface will be:

NACK.  Drivers should never add sockopt, and drivers should not abuse
netfilter hooks.
