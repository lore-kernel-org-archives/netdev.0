From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: display interface name as zone index when
 needed
Date: Mon, 10 Feb 2014 09:11:50 -0800
Message-ID: <20140210091150.506df1b7@nehalam.linuxnetplumber.net>
References: <1392020433-27554-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	NETDEV <netdev@vger.kernel.org>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:42329 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbaBJRLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 12:11:55 -0500
Received: by mail-pa0-f48.google.com with SMTP id kx10so6421209pab.21
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 09:11:55 -0800 (PST)
In-Reply-To: <1392020433-27554-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Feb 2014 09:20:33 +0100
Francois-Xavier Le Bail <fx.lebail@yahoo.com> wrote:

>  
> +extern char *if_indextoname(unsigned int ifindex, char *ifname);
> +

The same functionality index to name already exists in iproute2
library as ll_index_to_name. Please use that instead.
