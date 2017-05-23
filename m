From: Romain Perier <romain.perier@collabora.com>
Subject: Re: [PATCH v9 06/15] mlx5: Replace PCI pool old API
Date: Tue, 23 May 2017 10:53:36 +0200
Message-ID: <18745ec7-020a-a3d2-3e50-6a2405baaac2@collabora.com>
References: <20170522164907.22915-1-romain.perier@collabora.com>
 <20170522164907.22915-7-romain.perier@collabora.com>
 <20170523072743.GJ17751@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20170523072743.GJ17751@mtr-leonro.local>
Content-Language: en-US
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,


Le 23/05/2017 à 09:27, Leon Romanovsky a écrit :
> On Mon, May 22, 2017 at 06:48:58PM +0200, Romain Perier wrote:
>> The PCI pool API is deprecated. This commit replaces the PCI pool old
>> API by the appropriate function with the DMA pool API.
>>
>> Signed-off-by: Romain Perier <romain.perier@collabora.com>
>> Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
>> Acked-by: Doug Ledford <dledford@redhat.com>
>> Tested-by: Doug Ledford <dledford@redhat.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++++-----
>>  include/linux/mlx5/driver.h                   |  2 +-
>>  2 files changed, 7 insertions(+), 6 deletions(-)
>>
> Who is supposed to merge this patch series?
>
> Acked-by: Leon Romanovsky <leonro@mellanox.com>
Each maintainer of the corresponding subsystem, can take a patch, I
guess. No ?

Romain
