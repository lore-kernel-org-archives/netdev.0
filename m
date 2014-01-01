From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 2/2] mlx4_en: Only cycle port if HW timestamp
 config changes
Date: Wed, 1 Jan 2014 10:47:28 +0100
Message-ID: <20140101094728.GB7682@netboy>
References: <1388511580-3657-1-git-send-email-shawn.bohrer@gmail.com>
 <1388511580-3657-3-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:63759 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbaAAJrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 04:47:39 -0500
Received: by mail-ea0-f175.google.com with SMTP id z10so5835158ead.34
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 01:47:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1388511580-3657-3-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 31, 2013 at 11:39:40AM -0600, Shawn Bohrer wrote:
> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> 
> If the hwtstamp_config matches what is currently set for the device then
> simply return.  Without this change any program that tries to enable
> hardware timestamps will cause the link to cycle even if hardware
> timstamps were already enabled.
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_clock.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)

Acked-by: Richard Cochran <richardcochran@gmail.com>
