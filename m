From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/4] Add new timeval_to_sec function
Date: Mon, 23 Jul 2007 13:24:45 +0200
Message-ID: <46A48FFD.4070902@trash.net>
References: <20070723101159.32ef3bdd.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	varuncha@in.ibm.com
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61103 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbXGWLYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 07:24:48 -0400
In-Reply-To: <20070723101159.32ef3bdd.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Varun Chandramohan wrote:
>  /**
> + * timeval_to_sec - Convert timeval to seconds
> + * @tv:         pointer to the timeval variable to be converted
> + *
> + * Returns the seconds representation of timeval parameter.
> + */
> +static inline time_t timeval_to_sec(const struct timeval *tv)
> +{
> +	return (tv->tv_sec + (tv->tv_usec + 500000)/1000000);
> +}


I don't think you should round down timeout values.
