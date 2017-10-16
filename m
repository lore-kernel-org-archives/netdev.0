From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 00/15] make structure field, function arguments and structures const
Date: Mon, 16 Oct 2017 17:18:39 +0200
Message-ID: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
        alexander.shishkin@linux.intel.com, jic23@kernel.org,
        knaack.h@gmx.de, lars@metafoo.de, pmeerw@pmeerw.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, hch@lst.de, sagi@grimberg.me,
        kishon@ti.com, bhelgaas@google.com, nab@linux-iscsi.org,
        balbi@kernel.org, gregkh@linuxfoundation.org,
        laurent.pinchart@ideasonboard.com, jlbec@evilplan.org,
        ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-usb@vger.kernel.org,
        cluster-devel@redh
Return-path: <linux-acpi-owner@vger.kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the ci_type field and some function arguments as const. After this
change, make config_item_type structures as const.

* Changes in v2- Combine all the followup patches and the constification
patches into a series.

Bhumika Goyal (15):
  configfs: make ci_type field, some pointers and function arguments
    const
  usb: gadget: make config_item_type structures const
  target: make config_item_type const
  iio: make function argument and some structures const
  ocfs2/cluster: make config_item_type const
  PCI: endpoint: make config_item_type const
  usb: gadget: configfs: make config_item_type const
  nvmet: make config_item_type const
  ACPI: configfs: make config_item_type const
  nullb: make config_item_type const
  stm class: make config_item_type const
  RDMA/cma: make config_item_type const
  netconsole: make config_item_type const
  dlm: make config_item_type const
  configfs: make config_item_type const

 drivers/acpi/acpi_configfs.c                 |  6 ++--
 drivers/block/null_blk.c                     |  4 +--
 drivers/hwtracing/stm/policy.c               | 10 +++---
 drivers/iio/dummy/iio_simple_dummy.c         |  2 +-
 drivers/iio/industrialio-configfs.c          |  2 +-
 drivers/iio/industrialio-sw-device.c         |  6 ++--
 drivers/iio/industrialio-sw-trigger.c        |  6 ++--
 drivers/iio/trigger/iio-trig-hrtimer.c       |  2 +-
 drivers/iio/trigger/iio-trig-loop.c          |  2 +-
 drivers/infiniband/core/cma_configfs.c       |  8 ++---
 drivers/net/netconsole.c                     |  4 +--
 drivers/nvme/target/configfs.c               | 30 ++++++++---------
 drivers/pci/endpoint/pci-ep-cfs.c            | 12 +++----
 drivers/target/iscsi/iscsi_target_stat.c     | 12 +++----
 drivers/target/target_core_configfs.c        | 14 ++++----
 drivers/target/target_core_stat.c            | 16 ++++-----
 drivers/usb/gadget/configfs.c                | 10 +++---
 drivers/usb/gadget/function/f_acm.c          |  2 +-
 drivers/usb/gadget/function/f_ecm.c          |  2 +-
 drivers/usb/gadget/function/f_eem.c          |  2 +-
 drivers/usb/gadget/function/f_fs.c           |  2 +-
 drivers/usb/gadget/function/f_hid.c          |  2 +-
 drivers/usb/gadget/function/f_loopback.c     |  2 +-
 drivers/usb/gadget/function/f_mass_storage.c |  4 +--
 drivers/usb/gadget/function/f_midi.c         |  2 +-
 drivers/usb/gadget/function/f_ncm.c          |  2 +-
 drivers/usb/gadget/function/f_obex.c         |  2 +-
 drivers/usb/gadget/function/f_phonet.c       |  2 +-
 drivers/usb/gadget/function/f_printer.c      |  2 +-
 drivers/usb/gadget/function/f_rndis.c        |  2 +-
 drivers/usb/gadget/function/f_serial.c       |  2 +-
 drivers/usb/gadget/function/f_sourcesink.c   |  2 +-
 drivers/usb/gadget/function/f_subset.c       |  2 +-
 drivers/usb/gadget/function/f_tcm.c          |  2 +-
 drivers/usb/gadget/function/f_uac1.c         |  2 +-
 drivers/usb/gadget/function/f_uac1_legacy.c  |  2 +-
 drivers/usb/gadget/function/f_uac2.c         |  2 +-
 drivers/usb/gadget/function/uvc_configfs.c   | 50 ++++++++++++++--------------
 fs/configfs/dir.c                            | 10 +++---
 fs/configfs/item.c                           |  6 ++--
 fs/configfs/symlink.c                        |  4 +--
 fs/dlm/config.c                              | 16 ++++-----
 fs/ocfs2/cluster/heartbeat.c                 |  4 +--
 fs/ocfs2/cluster/nodemanager.c               |  8 ++---
 include/linux/configfs.h                     |  8 ++---
 include/linux/iio/sw_device.h                |  2 +-
 include/linux/iio/sw_trigger.h               |  2 +-
 include/target/iscsi/iscsi_target_stat.h     | 12 +++----
 samples/configfs/configfs_sample.c           |  8 ++---
 49 files changed, 159 insertions(+), 159 deletions(-)

-- 
1.9.1

