From: Joe Perches <joe@perches.com>
Subject: Re: sysfs_format_mac
Date: Tue, 16 Jul 2013 16:32:12 -0700
Message-ID: <1374017532.1949.57.camel@joe-AO722>
References: <1374007586.1949.25.camel@joe-AO722>
	 <20130716.135857.1132486724952537431.davem@davemloft.net>
	 <1374009169.1949.38.camel@joe-AO722>
	 <20130716.162549.1211987183945448630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53701 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755209Ab3GPXcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 19:32:13 -0400
In-Reply-To: <20130716.162549.1211987183945448630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-16 at 16:25 -0700, David Miller wrote:
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
[]
>  ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
[]
> -       l = _format_mac_addr(buf, PAGE_SIZE, addr, len);
> -       l += scnprintf(buf + l, PAGE_SIZE - l, "\n");
[]
> +       return scnprintf(buf, PAGE_SIZE, "%*phC", len, addr);

missing newline?

	scnprintf(buf, PAGE_ SIZE, "%*phC\n", len, addr);
