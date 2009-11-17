From: Rasesh Mody <rmody@brocade.com>
Subject: RE: Subject: [PATCH 5/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 17 Nov 2009 00:32:45 -0800
Message-ID: <CBE1CC7A31453F4CA63C13EFCE6A0F6C05BAD1DD1B@HQ-EXCH-7.corp.brocade.com>
References: <200911130346.nAD3kquT001065@blc-10-10.brocade.com>
 <20091112210751.06e2d3c6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:40642 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116AbZKQIcm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 03:32:42 -0500
In-Reply-To: <20091112210751.06e2d3c6@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +
> +#define wwn_t u64
> +#define lun_t u64

"No need for obfuscation, at least use a typedef."

Hi Stephen,

When using a typedef in place of #define for wwn_t we are getting check-patch warning. Is it advisable to use a typedef?

- Rasesh
