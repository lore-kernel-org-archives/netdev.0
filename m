From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 15/61] net: struct device - replace bus_id with
 dev_name(), dev_set_name()
Date: Tue, 24 Mar 2009 20:31:11 -0700
Message-ID: <20090324203111.0d3f5de1@nehalam>
References: <20090325001659.GA22461@kroah.com>
	<1237940825-22904-15-git-send-email-gregkh@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Kay Sievers <kay.sievers@vrfy.org>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757317AbZCYDbo@vger.kernel.org>
In-Reply-To: <1237940825-22904-15-git-send-email-gregkh@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Mar 2009 17:26:19 -0700
Greg Kroah-Hartman <gregkh@suse.de> wrote:

> From: Kay Sievers <kay.sievers@vrfy.org>
> 
> Cc: davem@davemloft.net
> Cc: netdev@vger.kernel.org
> Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
> Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
> ---
>  drivers/net/arm/ks8695net.c  |    2 +-
>  drivers/net/au1000_eth.c     |    8 ++++----
>  drivers/net/bfin_mac.c       |   12 ++++++------
>  drivers/net/bmac.c           |    2 +-
>  drivers/net/cpmac.c          |    2 +-
>  drivers/net/declance.c       |    6 +++---
>  drivers/net/depca.c          |    6 +++---
>  drivers/net/ehea/ehea_main.c |    2 +-
>  drivers/net/jazzsonic.c      |    6 ++++--
>  drivers/net/macb.c           |   10 +++++-----
>  drivers/net/macsonic.c       |   15 ++++++++-------
>  drivers/net/mv643xx_eth.c    |    2 +-
>  drivers/net/sb1250-mac.c     |   10 +++++-----
>  drivers/net/smc911x.c        |    2 +-
>  drivers/net/smc91x.c         |    2 +-
>  drivers/net/smsc911x.c       |    7 ++++---
>  drivers/net/smsc9420.c       |    4 ++--
>  drivers/net/tc35815.c        |    4 ++--
>  drivers/net/xtsonic.c        |    2 +-
>  19 files changed, 54 insertions(+), 50 deletions(-)
> 

I know this is needed, but could please put some more explicit rational
in changelog.
