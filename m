From: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 00/15] add Intel(R) X722 iWARP driver
Date: Wed, 16 Dec 2015 13:58:24 -0600
Message-ID: <1450295919-17292-1-git-send-email-faisal.latif@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series contains the addition of the i40iw.ko driver.

This driver provides iWARP RDMA functionality for the Intel(R) X722
Ethernet controller for PCI Physical Functions. It also has support
for Virtual Function driver (i40iwvf.ko) that will be part of seperate
patch series.

It cooperates with the Intel(R) X722 base driver (i40e.ko) to allocate
resources and program the controller.

This series include 1 patch to i40e.ko to provide interface support
to i40iw.ko. The interface provides a driver registration mechanism,
resource allocations, and device reset coordination mechanisms.

This patch series is based on Doug Ledford's
/github.com/dledford/linux.git


Anjali Singhai Jain (1)
net/ethernet/intel/i40e: Add support for client interface for IWARP driver

Faisal Latif(14):
infiniband/hw/i40iw: add main, hdr, status
infiniband/hw/i40iw: add connection management code
infiniband/hw/i40iw: add puda code
infiniband/hw/i40iw: add pble resource files
infiniband/hw/i40iw: add hmc resource files
infiniband/hw/i40iw: add hw and utils files
infiniband/hw/i40iw: add files for iwarp interface
infiniband/hw/i40iw: add file to handle cqp calls
infiniband/hw/i40iw: add hardware related header files
infiniband/hw/i40iw: add X722 register file
infiniband/hw/i40iw: user kernel shared files
infiniband/hw/i40iw: virtual channel handling files
infiniband/hw/i40iw: Kconfig and Kbuild for iwarp module
infiniband/hw/i40iw: changes for build of i40iw module

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
