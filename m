From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v4 04/14] QLogic VNIC: Implementation of Control path of
 communication protocol
Date: Tue, 10 Jun 2008 15:21:47 -0700
Message-ID: <20080610152147.042b230f@extreme>
References: <20080610205633.11186.45499.stgit@dale>
	<20080610210415.11186.95157.stgit@dale>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, poornima.kamath@qlogic.com,
	amar.mudrankit@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:47312 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754464AbYFJWVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:21:54 -0400
In-Reply-To: <20080610210415.11186.95157.stgit@dale>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2008 17:04:15 -0400
Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:

> +#ifdef CONFIG_INFINIBAND_QLGC_VNIC_STATS
> +	struct {
> +		cycles_t	request_time;	/* intermediate value */
> +		cycles_t	response_time;
> +		u32		response_num;
> +		cycles_t	response_max;
> +		cycles_t	response_min;
> +		u32		timeout_num;
> +	} statistics;

Shouldn't you be using ktime_t rather than cycles_t? And then convert
it to some standard time base (ns, ms, or USER_HZ) when reporting
to user space.
