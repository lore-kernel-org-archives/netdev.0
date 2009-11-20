From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Fri, 20 Nov 2009 15:42:09 -0800
Message-ID: <20091120154209.01edcbb2@nehalam>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58154 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753054AbZKTXmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 18:42:24 -0500
In-Reply-To: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Nov 2009 15:28:58 -0800
Tom Herbert <therbert@google.com> wrote:

> @@ -861,6 +884,9 @@ struct net_device {
> 
>  	struct netdev_queue	rx_queue;
> 
> +	struct dev_rps_maps	*dev_rps_maps;	/* Per-NAPI maps for
> +						   receive packet steeing */
> +

How does this work for devices with:
   * multiqueue - one device has multiple NAPI instances
   * mulitport  - one NAPI shared by multiple devices

-- 
