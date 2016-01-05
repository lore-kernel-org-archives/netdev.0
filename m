From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V3 3/4] net/mlx5e: Add HW timestamping (TS)
 support
Date: Tue, 5 Jan 2016 13:43:46 +0100
Message-ID: <20160105124346.GA5433@localhost.localdomain>
References: <1451393912-13736-1-git-send-email-saeedm@mellanox.com>
 <1451393912-13736-4-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>, saeedm@dev.mellanox.co.il
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36371 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbcAEMnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 07:43:52 -0500
Received: by mail-wm0-f47.google.com with SMTP id l65so21326913wmf.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 04:43:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1451393912-13736-4-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2015 at 02:58:31PM +0200, Saeed Mahameed wrote:
> From: Eran Ben Elisha <eranbe@mellanox.com>
> 
> Add support for enable/disable HW timestamping for incoming and/or
> outgoing packets. To enable/disable HW timestamping appropriate
> ioctl should be used. Currently HWTSTAMP_FILTER_ALL/NONE and
> HWTSAMP_TX_ON/OFF only are supported. Make all relevant changes in
> RX/TX flows to consider TS request and plant HW timestamps into
> relevant structures.
> 
> Add internal clock for converting hardware timestamp to nanoseconds. In
> addition, add a service task to catch internal clock overflow, to make
> sure timestamping is accurate.
> 
> Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
