From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 2/5] drivers/net: delete all code/drivers depending on
 CONFIG_MCA
Date: Thu, 17 May 2012 17:20:39 -0400
Message-ID: <20120517212039.GC27789@windriver.com>
References: <1337272841-25931-1-git-send-email-paul.gortmaker@windriver.com>
 <1337272841-25931-3-git-send-email-paul.gortmaker@windriver.com>
 <4FB52C99.6010303@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <linux-kernel@vger.kernel.org>, <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:65516 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933056Ab2EQVUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 17:20:44 -0400
Content-Disposition: inline
In-Reply-To: <4FB52C99.6010303@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH 2/5] drivers/net: delete all code/drivers depending on CONFIG_MCA] On 17/05/2012 (Thu 12:51) Paul Gortmaker wrote:

> On 12-05-17 12:40 PM, Paul Gortmaker wrote:
> 
> [..]
> 
> >  18 files changed, 18 insertions(+), 5288 deletions(-)
> >  delete mode 100644 drivers/net/ethernet/8390/ne2.c
> >  delete mode 100644 drivers/net/ethernet/8390/smc-mca.c
> >  delete mode 100644 drivers/net/ethernet/i825xx/3c523.c
> >  delete mode 100644 drivers/net/ethernet/i825xx/3c523.h
> >  delete mode 100644 drivers/net/ethernet/i825xx/3c527.c
> 
> I can also obviously delete 3c527.h too.  Not sure why I didn't
> notice that until just now...  :(

I've layered the above commit (with 3c527.h deleted) onto today's
net-next, did a quick re-test of x86_64 allmodconfig and put it
on a branch as per below (vs sending a 5000+ line patch).

Thanks,
Paul.
---

The following changes since commit bc6a4744b827c5a78ca591acca81809bddb8b2db:

  net/mlx4_en: num cores tx rings for every UP (2012-05-17 16:17:50 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git delete-mca-net-drivers

for you to fetch changes up to a5e371f61ad33c07b28e7c9b60c78d71fdd34e2a:

  drivers/net: delete all code/drivers depending on CONFIG_MCA (2012-05-17 16:37:41 -0400)

----------------------------------------------------------------
Paul Gortmaker (1):
      drivers/net: delete all code/drivers depending on CONFIG_MCA

 Documentation/networking/3c509.txt     |    1 -
 Documentation/networking/fore200e.txt  |    6 +-
 drivers/net/Space.c                    |   16 +-
 drivers/net/ethernet/3com/3c509.c      |  123 +---
 drivers/net/ethernet/8390/Kconfig      |   24 -
 drivers/net/ethernet/8390/Makefile     |    1 -
 drivers/net/ethernet/8390/ne2.c        |  798 ---------------
 drivers/net/ethernet/8390/smc-mca.c    |  575 -----------
 drivers/net/ethernet/amd/depca.c       |  210 +----
 drivers/net/ethernet/fujitsu/at1700.c  |  120 +---
 drivers/net/ethernet/i825xx/3c523.c    | 1312 -------------------------
 drivers/net/ethernet/i825xx/3c523.h    |  355 -------
 drivers/net/ethernet/i825xx/3c527.c    | 1660 --------------------------------
 drivers/net/ethernet/i825xx/3c527.h    |   81 --
 drivers/net/ethernet/i825xx/Kconfig    |   22 -
 drivers/net/ethernet/i825xx/Makefile   |    2 -
 drivers/net/ethernet/i825xx/eexpress.c |   60 +--
 drivers/net/ethernet/natsemi/Kconfig   |   20 +-
 drivers/net/ethernet/natsemi/Makefile  |    1 -
 19 files changed, 18 insertions(+), 5369 deletions(-)
 delete mode 100644 drivers/net/ethernet/8390/ne2.c
 delete mode 100644 drivers/net/ethernet/8390/smc-mca.c
 delete mode 100644 drivers/net/ethernet/i825xx/3c523.c
 delete mode 100644 drivers/net/ethernet/i825xx/3c523.h
 delete mode 100644 drivers/net/ethernet/i825xx/3c527.c
 delete mode 100644 drivers/net/ethernet/i825xx/3c527.h
