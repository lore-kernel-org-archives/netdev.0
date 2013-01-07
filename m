From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [RFC/PATCH net-next 0/1] Delete obsolete 8390 EISA drivers
Date: Mon,  7 Jan 2013 13:16:57 -0500
Message-ID: <1357582618-17183-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54849 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585Ab3AGSRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 13:17:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'd like to propose that we get rid of these old 8390 EISA drivers.
Of the five deleted here, I wrote four -- and while that doesn't give
me any authority for deletion above anyone else, it does at least
allow me to comment on the absolute absence of anyone reaching
out to the driver author for assistance in the last dozen years.

Eventually we'll probably get rid of EISA bus support, since in
x86, the hardware is close to 20 years old and already too resource
constrained to be useful today.  However there might still be
a few DEC Alpha enthusiasts with old EISA machines kept alive,
and so I expect we'll have to wait a bit longer to get unanimous
agreement to proceed with the full EISA removal (although I'd
love to be proven wrong on that).

Most of the DEC Alpha machines shipped in a PCI configuration, and
even the few that were EISA had DEC tulip based ethernet and no
reason to be needing the inferior 8390 technology.  So the interest
here for any possible DEC enthusiasts with EISA boxes about these
old 8390 drivers should be nil.

These really were rare cards -- in fact the smc-ultra32 is the only
one that I'd ever seen in person.  Even back in the mid 90's when
the drivers were written, I would guess that the user base was less
than 10 people across all of them.

The following patch was created with --irreversible-delete for
ease of review (it skips showing the content of files that are
deleted); however the complete patch can be pulled as per below.

Paul.
---

The following changes since commit 483f777266f5da205459c290994bd3cda5f1f6bc:

  drivers/net: remove orphaned references to micro channel (2013-01-06 21:13:33 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git delete-8390-EISA

for you to fetch changes up to bca94cffabf5c9f2399da34eab00bd534bf3735b:

  drivers/net: delete 8390 based EISA drivers. (2013-01-07 10:24:26 -0500)

----------------------------------------------------------------
Paul Gortmaker (1):
      drivers/net: delete 8390 based EISA drivers.

 drivers/net/ethernet/8390/Kconfig       |  66 +----
 drivers/net/ethernet/8390/Makefile      |   5 -
 drivers/net/ethernet/8390/ac3200.c      | 431 -----------------------------
 drivers/net/ethernet/8390/es3210.c      | 445 ------------------------------
 drivers/net/ethernet/8390/lne390.c      | 433 -----------------------------
 drivers/net/ethernet/8390/ne3210.c      | 346 ------------------------
 drivers/net/ethernet/8390/smc-ultra32.c | 463 --------------------------------
 7 files changed, 2 insertions(+), 2187 deletions(-)
 delete mode 100644 drivers/net/ethernet/8390/ac3200.c
 delete mode 100644 drivers/net/ethernet/8390/es3210.c
 delete mode 100644 drivers/net/ethernet/8390/lne390.c
 delete mode 100644 drivers/net/ethernet/8390/ne3210.c
 delete mode 100644 drivers/net/ethernet/8390/smc-ultra32.c
