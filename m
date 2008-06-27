From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/4] Hold RTNL while calling dev_close()
Date: Fri, 27 Jun 2008 01:32:16 -0400
Message-ID: <48647B60.6040608@pobox.com>
References: <20080506182654.GF2217@solarflare.com> <20080506184147.GJ2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-x25-owner@vger.kernel.org>
In-Reply-To: <20080506184147.GJ2217@solarflare.com>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings wrote:
> dev_close() must be called holding the RTNL.  Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/wan/x25_asy.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)

applied


