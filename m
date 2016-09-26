From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH v5 00/16] Add Paravirtual RDMA Driver
Date: Mon, 26 Sep 2016 17:42:23 -0500
Message-ID: <20160926224223.GA3309@localhost>
References: <cover.1474759181.git.aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1474759181.git.aditr@vmware.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 24, 2016 at 04:21:24PM -0700, Adit Ranadive wrote:
>  MAINTAINERS                                    |    9 +
>  drivers/infiniband/Kconfig                     |    1 +
>  drivers/infiniband/hw/Makefile                 |    1 +
>  drivers/infiniband/hw/pvrdma/Kconfig           |    7 +
>  drivers/infiniband/hw/pvrdma/Makefile          |    3 +
>  drivers/infiniband/hw/pvrdma/pvrdma.h          |  473 +++++++++
>  drivers/infiniband/hw/pvrdma/pvrdma_cmd.c      |  117 +++
>  drivers/infiniband/hw/pvrdma/pvrdma_cq.c       |  426 +++++++++
>  drivers/infiniband/hw/pvrdma/pvrdma_defs.h     |  301 ++++++
>  drivers/infiniband/hw/pvrdma/pvrdma_dev_api.h  |  342 +++++++
>  drivers/infiniband/hw/pvrdma/pvrdma_doorbell.c |  127 +++
>  drivers/infiniband/hw/pvrdma/pvrdma_ib_verbs.h |  444 +++++++++
>  drivers/infiniband/hw/pvrdma/pvrdma_main.c     | 1220 ++++++++++++++++++++++++
>  drivers/infiniband/hw/pvrdma/pvrdma_misc.c     |  304 ++++++
>  drivers/infiniband/hw/pvrdma/pvrdma_mr.c       |  334 +++++++
>  drivers/infiniband/hw/pvrdma/pvrdma_qp.c       |  973 +++++++++++++++++++
>  drivers/infiniband/hw/pvrdma/pvrdma_verbs.c    |  577 +++++++++++
>  drivers/infiniband/hw/pvrdma/pvrdma_verbs.h    |  108 +++
>  drivers/net/vmxnet3/vmxnet3_int.h              |    3 +-
>  include/linux/pci_ids.h                        |    1 +
>  include/uapi/rdma/Kbuild                       |    2 +
>  include/uapi/rdma/pvrdma-abi.h                 |   99 ++
>  include/uapi/rdma/pvrdma-uapi.h                |  255 +++++

Hi Adit,

You don't need to cc linux-pci just because of the one-line change to
pci_ids.h.  I've already acked that, and the rest is just noise to the
main linux-pci audience.

Bjorn
