From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V1 3/4] net/mlx5e: Add HW timestamping (TS)
 support
Date: Sun, 20 Dec 2015 20:18:06 +0100
Message-ID: <20151220191806.GA2027@netboy>
References: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
 <1450355735-30846-4-git-send-email-saeedm@mellanox.com>
 <20151217201154.GA5975@localhost.localdomain>
 <CALzJLG_PdkDNnHVfV5XsD0pGJ5MXx7Tb-4kuLSFq3o4P2dG8KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36455 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbbLTTSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2015 14:18:11 -0500
Received: by mail-wm0-f66.google.com with SMTP id r67so9569883wmg.3
        for <netdev@vger.kernel.org>; Sun, 20 Dec 2015 11:18:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALzJLG_PdkDNnHVfV5XsD0pGJ5MXx7Tb-4kuLSFq3o4P2dG8KA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 20, 2015 at 03:08:18PM +0200, Saeed Mahameed wrote:
> Agree, but what will happen if the calculated period is too rapid ?
> shouldn't we have some kind of minimum ?

If the period is shorter than you can handle, then the clock will
overflow and is therefore unusable.

Thanks,
Richard
