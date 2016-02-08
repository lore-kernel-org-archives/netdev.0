From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 01/21] iplink: bridge: export bridge_id and
 designated_root
Date: Mon, 8 Feb 2016 14:21:54 -0800
Message-ID: <20160208142154.35f85b61@xeon-e3>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
	<1454932527-30569-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36475 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755975AbcBHWVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 17:21:41 -0500
Received: by mail-pa0-f48.google.com with SMTP id yy13so80144376pab.3
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 14:21:41 -0800 (PST)
In-Reply-To: <1454932527-30569-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  8 Feb 2016 12:55:07 +0100
Nikolay Aleksandrov <razor@blackwall.org> wrote:

>  
> +static void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf,
> +			      size_t len)
> +{
> +	const unsigned char *x = (const unsigned char *)id;
> +
> +	snprintf(buf, len, "%.2x%.2x.%.2x%.2x%.2x%.2x%.2x%.2x", x[0], x[1],
> +		 x[2], x[3], x[4], x[5], x[6], x[7]);
> +}

Please don't reinvent ether_ntoa_r
