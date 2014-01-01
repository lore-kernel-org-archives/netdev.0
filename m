From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Tue, 31 Dec 2013 16:53:05 -0800
Message-ID: <1388537594-24601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27211 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957AbaAAAx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Dec 2013 19:53:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements the Linux Virtual Function (VF) driver for
the Intel Ethernet Controller XL710 family.

The following are changes since commit 21eb218989523b7bee28900aaec9f9296b70fa27:
  net, sch: fix the typo in register_qdisc()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Greg Rose (8):
  i40evf: main driver core
  i40evf: transmit and receive functionality
  i40evf: core ethtool functionality
  i40evf: virtual channel interface
  i40evf: driver core headers
  i40evf: init code and hardware support
  i40evf: add driver to kernel build system
  i40evf: A0 silicon specific

 Documentation/networking/i40evf.txt                |   47 +
 MAINTAINERS                                        |    4 +-
 drivers/net/ethernet/intel/Kconfig                 |   19 +
 drivers/net/ethernet/intel/Makefile                |    1 +
 drivers/net/ethernet/intel/i40evf/Makefile         |   33 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |  927 ++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |  106 +
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 2153 +++++++++
 drivers/net/ethernet/intel/i40evf/i40e_alloc.h     |   55 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  254 ++
 drivers/net/ethernet/intel/i40evf/i40e_hmc.h       |  238 +
 drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h   |  165 +
 drivers/net/ethernet/intel/i40evf/i40e_osdep.h     |   72 +
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   84 +
 drivers/net/ethernet/intel/i40evf/i40e_register.h  | 4667 ++++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_status.h    |   97 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 1573 +++++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  296 ++
 drivers/net/ethernet/intel/i40evf/i40e_type.h      | 1152 +++++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  364 ++
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  321 ++
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  390 ++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 2353 ++++++++++
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  772 ++++
 24 files changed, 16142 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/i40evf.txt
 create mode 100644 drivers/net/ethernet/intel/i40evf/Makefile
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_adminq.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_adminq.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_alloc.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_common.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_hmc.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_osdep.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_prototype.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_register.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_status.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_txrx.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_txrx.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_type.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40evf.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40evf_main.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c

-- 
1.8.3.1
