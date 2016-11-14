From: Matthias Brugger <mbrugger@suse.com>
Subject: Re: [PATCH 0/5] net: thunderx: Miscellaneous fixes
Date: Mon, 14 Nov 2016 13:01:25 +0100
Message-ID: <2948c47d-0f15-8153-440b-7a2c753b7251@suse.com>
References: <1479120886-13425-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: sunil.kovvuri@gmail.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479120886-13425-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 14/11/16 11:54, sunil.kovvuri@gmail.com wrote:
> From: Sunil Goutham <sgoutham@cavium.com>
>
> This patchset includes fixes for incorrect LMAC credits,
> unreliable driver statistics, memory leak upon interface
> down e.t.c
>

Are these fixes relevant to for older kernels as well?
If so, please add "Cc: stable@vger.kernel.org" to the Sigend-off list.

Thanks,
Matthias

> Radha Mohan Chintakuntla (1):
>   net: thunderx: Introduce BGX_ID_MASK macro to extract bgx_id
>
> Sunil Goutham (4):
>   net: thunderx: Program LMAC credits based on MTU
>   net: thunderx: Fix configuration of L3/L4 length checking
>   net: thunderx: Fix VF driver's interface statistics
>   net: thunderx: Fix memory leak and other issues upon interface toggle
>
>  drivers/net/ethernet/cavium/thunder/nic.h          |  64 +++++----
>  drivers/net/ethernet/cavium/thunder/nic_main.c     |  37 +++--
>  drivers/net/ethernet/cavium/thunder/nic_reg.h      |   1 +
>  .../net/ethernet/cavium/thunder/nicvf_ethtool.c    | 105 +++++++-------
>  drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 153 +++++++++++----------
>  drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 118 +++++++++-------
>  drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  24 +---
>  drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |   4 +-
>  drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |   2 +
>  9 files changed, 274 insertions(+), 234 deletions(-)
>
