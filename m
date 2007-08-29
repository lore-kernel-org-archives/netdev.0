From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 1/1][RFC] add a private field to the sock structure
Date: Wed, 29 Aug 2007 19:09:37 +0100
Message-ID: <20070829180937.GA25729@infradead.org>
References: <20070829164114.868188182@f002726.toulouse-stg.fr.ibm.com> <20070829164714.637053362@f002726.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:49948 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbXH2SJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 14:09:39 -0400
Content-Disposition: inline
In-Reply-To: <20070829164714.637053362@f002726.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 29, 2007 at 06:41:15PM +0200, dlezcano@fr.ibm.com wrote:
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> Store private information for a socket
> 
> This patch adds a field to the common socket structure. This field
> is a anonymous pointer which allow to store an information about
> the socket

If you have orivtae information it should have a typed pointer to it.
Please also post the patches actually using this field.

