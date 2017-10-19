From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 02/15] usb: gadget: make config_item_type structures
        const
Date: Thu, 19 Oct 2017 16:06:57 +0200
Message-ID: <20171019140657.GA22233@lst.de>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com> <1508167134-6243-3-git-send-email-bhumirks@gmail.com> <1985905.z83BJQzMUS@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        rjw@rjwysocki.net, lenb@kernel.org,
        alexander.shishkin@linux.intel.com, jic23@kernel.org,
        knaack.h@gmx.de, lars@metafoo.de, pmeerw@pmeerw.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, hch@lst.de, sagi@grimberg.me,
        kishon@ti.com, bhelgaas@google.com, nab@linux-iscsi.org,
        balbi@kernel.org, gregkh@linuxfoundation.org, jlbec@evilplan.org,
        ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-usb@vger.kernel.org,
        cluster-devel@red
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1985905.z83BJQzMUS@avalon>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Now we have 9 const instances of the config_item_type structure that are 
> identical, with only the .ct_owner field set. Should they be all merged into a 
> single structure ?

I think that's a good idea.

But I'm about to slurp up this whole series into my tree, how about making
that an incremental patch?  
