From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 7/7] cxgb3 - Add SW LRO support
Date: Mon, 26 Feb 2007 05:13:04 +0000
Message-ID: <20070226051304.GA13626@infradead.org>
References: <20070225004423.20903.17036.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41991 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbXBZFNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 00:13:21 -0500
Content-Disposition: inline
In-Reply-To: <20070225004423.20903.17036.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 24, 2007 at 04:44:23PM -0800, divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Add all-in-sw lro support.

Doing this in a LLDD doesn't sound like a good idea.  Have you
tried doing this in the core networking code instead?
