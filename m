From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/1] Remove more unnecessary driver printk's
Date: Tue, 12 Sep 2006 11:44:58 -0400
Message-ID: <4506D5FA.4090200@pobox.com>
References: <20060911213918.GA1074@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: phdm@macqel.be, ralf@linux-mips.org, vesok@yahoo.com,
	thockin@hockin.org, rl@hellgate.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:11743 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751393AbWILPpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 11:45:17 -0400
To: Andy Gospodarek <andy@greyhouse.net>
In-Reply-To: <20060911213918.GA1074@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> As I promised last week, here is the first pass at removing all
> unnecessary printk's that exist in network device drivers currently in
> promiscuous mode.  The duplicate messages are not needed so they have
> been removed.  Some of these drivers are quite old and might not need an
> update, but I did them all anyway.
> 
> I am currently auditing the remaining conditional printk's and will send
> out a patch for those soon.
> 
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
> 
>  3c59x.c              |    2 +-
>  8139cp.c             |    4 +---
>  8139too.c            |    5 +----
>  amd8111e.c           |    5 ++---
>  ariadne.c            |    2 --
>  at1700.c             |    4 +---
>  atarilance.c         |    2 +-
>  au1000_eth.c         |    3 +--
>  eepro.c              |    3 +--
>  epic100.c            |    5 ++---
>  fealnx.c             |    6 ++----
>  fec.c                |    2 --
>  gianfar.c            |    3 ---
>  hamachi.c            |    6 ++----
>  ioc3-eth.c           |    4 +---
>  lance.c              |    4 +---
>  natsemi.c            |    7 ++-----
>  pci-skeleton.c       |    5 +----
>  pcmcia/fmvj18x_cs.c  |    4 +---
>  pcmcia/smc91c92_cs.c |    5 ++---
>  sb1250-mac.c         |    9 ---------
>  sis190.c             |    3 ---
>  sun3lance.c          |    2 +-
>  sundance.c           |    6 ++----
>  tulip/tulip_core.c   |    6 ++----
>  tulip/winbond-840.c  |    6 ++----
>  typhoon.c            |    6 ++----
>  ucc_geth.c           |    4 +---
>  via-rhine.c          |    7 ++-----
>  via-velocity.c       |    2 --
>  via-velocity.h       |    2 +-
>  yellowfin.c          |    6 ++----
>  32 files changed, 38 insertions(+), 102 deletions(-)

ACK, but does not apply to netdev-2.6.git#upstream...

