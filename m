From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] unix_diag: Fix definition of UNIX_DIAG_MAX
Date: Thu, 21 Mar 2013 14:40:43 +0000
Message-ID: <20130321144043.GD9046@casper.infradead.org>
References: <7c4a72239f4795677484c99c105ef5f27c12d246.1363871797.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50655 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932834Ab3CUOko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 10:40:44 -0400
Content-Disposition: inline
In-Reply-To: <7c4a72239f4795677484c99c105ef5f27c12d246.1363871797.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/13 at 02:17pm, Thomas Graf wrote:
> UNIX_DIAG_MAX should point to the maximum attribute type known
> instead of + 1. User space applications compiled against the
> old definition are currently passing through unknown attribute
> types while parsing.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Disregard this patch, the patch 

        [PATCH] net: fix *_DIAG_MAX constants

is more complete.
