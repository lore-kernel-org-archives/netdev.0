From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6.18] defxx: Big-endian hosts support
Date: Mon, 23 Oct 2006 15:48:44 +0100
Message-ID: <20061023144844.GA30864@infradead.org>
References: <Pine.LNX.4.64N.0610231330190.4426@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:26569 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S964901AbWJWOsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 10:48:55 -0400
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64N.0610231330190.4426@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 23, 2006 at 01:53:17PM +0100, Maciej W. Rozycki wrote:
> +	data = cpu_to_le32(data);

This is rather ugly and not provable by static typechecking.  Please
always use spearate variables/structs for device and host endian values,
and run the resulting driver through sparse to make sure everything is
correct.

