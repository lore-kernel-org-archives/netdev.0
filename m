From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Thu, 15 Dec 2016 09:56:11 -0700
Message-ID: <20161215165611.GB3264@obsidianresearch.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, dennis.dalessandro@intel.com,
        ira.weiny@intel.com
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:58608 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755007AbcLOQ4l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 11:56:41 -0500
Content-Disposition: inline
In-Reply-To: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2016 at 11:59:32PM -0800, Vishwanathapura, Niranjana wrote:
>  create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/Kconfig
>  create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/Makefile

Stil NAK on these paths, I already explained why 'sw' is totally
unsuitable. Put it in drivers/net or drivers/infiniband/ulp

Jason
