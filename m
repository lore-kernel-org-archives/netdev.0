From: Romain Perier <romain.perier@collabora.com>
Subject: Re: [PATCH v9 06/15] mlx5: Replace PCI pool old API
Date: Thu, 25 May 2017 13:37:33 +0200
Message-ID: <6913fc09-ed8b-7f4a-4273-522f7c83c705@collabora.com>
References: <20170522164907.22915-7-romain.perier@collabora.com>
 <20170523072743.GJ17751@mtr-leonro.local>
 <18745ec7-020a-a3d2-3e50-6a2405baaac2@collabora.com>
 <20170523.112658.1479025487863881513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: leon@kernel.org, dan.j.williams@intel.com, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com,
        jeffrey.t.kirsher@intel.com, stas.yakovlev@gmail.com,
        jejb@linux.vnet.ibm.com, martin.petersen@oracle.com,
        balbi@kernel.org, gregkh@linuxfoundation.org,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org, peter.senna@collabora.co.uk
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523.112658.1479025487863881513.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,


Le 23/05/2017 à 17:26, David Miller a écrit :
> From: Romain Perier <romain.perier@collabora.com>
> Date: Tue, 23 May 2017 10:53:36 +0200
>
>> Hello,
>>
>>
>> Le 23/05/2017 à 09:27, Leon Romanovsky a écrit :
>>> On Mon, May 22, 2017 at 06:48:58PM +0200, Romain Perier wrote:
>>>> The PCI pool API is deprecated. This commit replaces the PCI pool old
>>>> API by the appropriate function with the DMA pool API.
>>>>
>>>> Signed-off-by: Romain Perier <romain.perier@collabora.com>
>>>> Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
>>>> Acked-by: Doug Ledford <dledford@redhat.com>
>>>> Tested-by: Doug Ledford <dledford@redhat.com>
>>>> ---
>>>>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++++-----
>>>>  include/linux/mlx5/driver.h                   |  2 +-
>>>>  2 files changed, 7 insertions(+), 6 deletions(-)
>>>>
>>> Who is supposed to merge this patch series?
>>>
>>> Acked-by: Leon Romanovsky <leonro@mellanox.com>
>> Each maintainer of the corresponding subsystem, can take a patch, I
>> guess. No ?
> It might be easier to accumulate acks and you submit them as a series,
> in my opinion.
That's what I did already, no ?

Romain
