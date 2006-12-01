From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/3] NetXen: driver cleanup, removed unnecessary __iomem
 type casts
Date: Fri, 01 Dec 2006 08:15:43 -0800
Message-ID: <4570552F.7010401@osdl.org>
References: <200612011336.kB1DaMQL014614@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, romieu@fr.zoreil.com,
	sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:30609 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031552AbWLAQQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 11:16:41 -0500
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <200612011336.kB1DaMQL014614@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit S. Kale wrote:


> +#define NUM_SUPPORTED_BOARDS (sizeof(netxen_boards)/sizeof(struct netxen_brdinfo
>   
You could use ARRAYSIZE(netxen_boards) for this you know.
