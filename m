From: Chris Wedgwood <cw@f00f.org>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Mon, 19 Jun 2006 22:35:36 -0700
Message-ID: <20060620053536.GA10311@tuatara.stupidest.org>
References: <1150278004.26181.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.sbc.mail.mud.yahoo.com ([68.142.198.206]:28244 "HELO
	smtp107.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S932497AbWFTFfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 01:35:39 -0400
To: Jesper Dangaard Brouer <hawk@comx.dk>
Content-Disposition: inline
In-Reply-To: <1150278004.26181.35.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2006 at 11:40:04AM +0200, Jesper Dangaard Brouer wrote:

> The Linux traffic's control engine inaccurately calculates
> transmission times for packets sent over ADSL links.  For some
> packet sizes the error rises to over 50%.  This occurs because ADSL
> uses ATM as its link layer transport, and ATM transmits packets in
> fixed sized 53 byte cells.

What if AAL5 is used?  The cell-alignment math is going to be wrong
there surely?

