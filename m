From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 01/15] configfs: make ci_type field, some pointers and
 function arguments const
Date: Tue, 17 Oct 2017 12:24:27 +0200
Message-ID: <20171017102427.GB25786@kroah.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
 <1508167134-6243-2-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
        alexander.shishkin@linux.intel.com, jic23@kernel.org,
        knaack.h@gmx.de, lars@metafoo.de, pmeerw@pmeerw.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, hch@lst.de, sagi@grimberg.me,
        kishon@ti.com, bhelgaas@google.com, nab@linux-iscsi.org,
        balbi@kernel.org, laurent.pinchart@ideasonboard.com,
        jlbec@evilplan.org, ccaulfie@redhat.com, teigland@redhat.com,
        mfasheh@versity.com, linux-acpi@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-iio@vger.kernel.org,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-nvme@lists.infradead.org, linux-pci@vger.kernel.org,
        linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
        linux-usb@vger.kernel.org, cluster-devel@redhat.com,
        ocfs2-devel@oss.orac
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1508167134-6243-2-git-send-email-bhumirks@gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2017 at 05:18:40PM +0200, Bhumika Goyal wrote:
> The ci_type field of the config_item structure do not modify the fields
> of the config_item_type structure it points to. And the other pointers
> initialized with ci_type do not modify the fields as well.
> So, make the ci_type field and the pointers initialized with ci_type
> as const.
> 
> Make the struct config_item_type *type function argument of functions
> config_{item/group}_init_type_name const as the argument in both the
> functions is only stored in the ci_type field of a config_item structure
> which is now made const.
> Make the argument of configfs_register_default_group const as it is
> only passed to the argument of the function config_group_init_type_name
> which is now const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
> * Changes in v2- Combine all the followup patches and the constification
> patches into a series.
> 
>  fs/configfs/dir.c        | 10 +++++-----
>  fs/configfs/item.c       |  6 +++---
>  fs/configfs/symlink.c    |  4 ++--
>  include/linux/configfs.h |  8 ++++----
>  4 files changed, 14 insertions(+), 14 deletions(-)

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
