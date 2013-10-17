From: David Miller <davem@davemloft.net>
Subject: Re: [patch] yam: integer underflow in yam_ioctl()
Date: Thu, 17 Oct 2013 15:54:22 -0400 (EDT)
Message-ID: <20131017.155422.1244517906591812199.davem@davemloft.net>
References: <20131014121931.GI6247@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpr@f6fbb.org, linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20131014121931.GI6247@mwanda>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 14 Oct 2013 15:28:38 +0300

> We cap bitrate at YAM_MAXBITRATE in yam_ioctl(), but it could also be
> negative.  I don't know the impact of using a negative bitrate but let's
> prevent it.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
