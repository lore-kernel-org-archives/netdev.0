From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bnx2x: VF RSS support
Date: Thu, 05 Sep 2013 21:26:43 -0700
Message-ID: <1378441603.31445.2.camel@edumazet-glaptop>
References: <1378292962-5537-1-git-send-email-ariele@broadcom.com>
	 <20130905.124540.1074524380635734466.davem@davemloft.net>
	 <1378441293.31445.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:61854 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713Ab3IFE0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 00:26:45 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so2822086pab.22
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 21:26:44 -0700 (PDT)
In-Reply-To: <1378441293.31445.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-05 at 21:21 -0700, Eric Dumazet wrote:
> On Thu, 2013-09-05 at 12:45 -0400, David Miller wrote:
> > From: "Ariel Elior" <ariele@broadcom.com>
> > Date: Wed, 4 Sep 2013 14:09:20 +0300
> > 
> > > This patch series adds the capability for VF functions to use multiple queues
> > > and Receive / Transmit side scaling.
> > > 
> > > Patch #1 enhances the PF's side database to allow for multiple queues per PF
> > > and configure the HW appropriately, and the PF side of the VF PF channel
> > > message for configuring the RSS.
> > > 
> > > Patch #2 adds to the VF side the ability to request multiple queues, and if
> > > obtained to configure RSS for them over the VF PF channel.
> > 
> > Series applied, thanks.
> 
> Hmmm
> 
>   CC [M]  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.o
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c: In function 'bnx2x_rss':
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c:2021:3: error: implicit declaration of function 'bnx2x_vfpf_config_rss' [-Werror=implicit-function-declaration]
> cc1: some warnings being treated as errors
> make[6]: *** [drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.o] Error 1
> make[5]: *** [drivers/net/ethernet/broadcom/bnx2x] Error 2
> make[4]: *** [drivers/net/ethernet/broadcom] Error 2
> make[3]: *** [drivers/net/ethernet] Error 2
> make[2]: *** [drivers/net] Error 2
> make[1]: *** [drivers] Error 2
> 


root@edumazet-glaptop:/usr/src/net-next# grep BNX2 .config
CONFIG_SCSI_BNX2_ISCSI=m
CONFIG_SCSI_BNX2X_FCOE=m
CONFIG_BNX2=m
CONFIG_BNX2X=m
# CONFIG_BNX2X_SRIOV is not set
