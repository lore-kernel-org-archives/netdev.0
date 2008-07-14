From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH RFC 00/10] mlx4_en: Mellanox ConnectX 10G NIC driver
Date: Mon, 14 Jul 2008 17:40:29 +0300
Message-ID: <487B655D.7030502@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liran Liss <liranl@mellanox.co.il>,
	tziporet@mellanox.co.il, Roland Dreier <rdreier@cisco.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:45380 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753542AbYGNOsK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 10:48:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jeff,

The series of the following 10 patches implements the Mellanox Technologies
ConnectX 10G Nic driver - mlx4_en.

The ConnectX can operate as an InfiniBand adapter, as an Ethernet NIC, or as
a Fibre Channel (FC) HBA.
Hence, the mlx4_en module is part of the ConnectX drivers, which also includes
a low level bus-driver - mlx4_core - and an Infiniband driver - mlx4_ib - that are
already in the kernel and maintained by Roland Dreier.

mlx4_en implements a standard Ethernet netdevice and handles all the Ethernet-related
logic of ConnectX.

This series of patches are based on patches that were already sent to mlx4_core module.
See http://lists.openfabrics.org/pipermail/general/2008-July/052686.html for most updated patches.
If you wish that we will submit them to this list too please let us know.

Summary of changes:
---
 drivers/net/Kconfig             |    9 +
 drivers/net/mlx4/Makefile       |    5 +
 drivers/net/mlx4/en_cq.c        |  132 +++++
 drivers/net/mlx4/en_main.c      |  244 +++++++++
 drivers/net/mlx4/en_netdev.c    | 1076 ++++++++++++++++++++++++++++++++++++++
 drivers/net/mlx4/en_params.c    |  619 ++++++++++++++++++++++
 drivers/net/mlx4/en_port.c      |  235 +++++++++
 drivers/net/mlx4/en_port.h      |  586 +++++++++++++++++++++
 drivers/net/mlx4/en_resources.c |   99 ++++
 drivers/net/mlx4/en_rx.c        | 1084 +++++++++++++++++++++++++++++++++++++++
 drivers/net/mlx4/en_tx.c        |  754 +++++++++++++++++++++++++++
 drivers/net/mlx4/mlx4_en.h      |  645 +++++++++++++++++++++++
 12 files changed, 5488 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/mlx4/en_cq.c
 create mode 100644 drivers/net/mlx4/en_main.c
 create mode 100644 drivers/net/mlx4/en_netdev.c
 create mode 100644 drivers/net/mlx4/en_params.c
 create mode 100644 drivers/net/mlx4/en_port.c
 create mode 100644 drivers/net/mlx4/en_port.h
 create mode 100644 drivers/net/mlx4/en_resources.c
 create mode 100644 drivers/net/mlx4/en_rx.c
 create mode 100644 drivers/net/mlx4/en_tx.c
 create mode 100644 drivers/net/mlx4/mlx4_en.h


Liran & Yevgeny


