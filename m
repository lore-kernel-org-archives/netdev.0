From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qeth: avoid buffer overflow in snmp ioctl
Date: Tue, 05 Nov 2013 23:51:07 -0500 (EST)
Message-ID: <20131105.235107.712124797485310428.davem@davemloft.net>
References: <20131105141400.GA29477@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: blaschka@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174Ab3KFEvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 23:51:09 -0500
In-Reply-To: <20131105141400.GA29477@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Tue, 5 Nov 2013 15:14:00 +0100

> +	if (req_len > QETH_BUFSIZE - IPA_PDU_HEADER_SIZE
> +				   - sizeof(struct qeth_ipacmd_hdr)
> +				   - sizeof(struct qeth_ipacmd_setadpparms_hdr))
> +		return -EINVAL;

Please fix the indentation and parenthesize the more complicated right
side of the expression, it should be something like:

	if (req_len > (QETH_BUFSIZE - IPA_PDU_HEADER_SIZE -
		       sizeof(struct qeth_ipacmd_hdr) -
		       sizeof(struct qeth_ipacmd_setadpparms_hdr)))

Thanks.
