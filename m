From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1] ks8851_mll: basic ethernet statistics
Date: Sun, 10 Mar 2013 16:44:49 -0400 (EDT)
Message-ID: <20130310.164449.2204801487851233943.davem@davemloft.net>
References: <FD9AD8C5375B924CABC56D982DB3A8020B4F7D67@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Charles.Li@Micrel.Com
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab3CJUol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 16:44:41 -0400
In-Reply-To: <FD9AD8C5375B924CABC56D982DB3A8020B4F7D67@EXMB1.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Fri, 8 Mar 2013 22:58:20 +0000

>  	while (ks->frame_cnt--) {
> +		if (unlikely(!(frame_hdr->sts & RXFSHR_RXFV) ||
> +		    frame_hdr->len >= RX_BUF_SIZE ||
> +		    frame_hdr->len <= 0)) {

You need to indent the last two lines so that the first character
lines up with the openning parenthesis of the unlikely() not
the if() statement.
