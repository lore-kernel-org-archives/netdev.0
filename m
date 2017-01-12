From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunderx: acpi: fix LMAC initialization
Date: Thu, 12 Jan 2017 16:50:30 -0500 (EST)
Message-ID: <20170112.165030.1356353468945456367.davem@davemloft.net>
References: <1484234886-22172-1-git-send-email-Vadim.Lomovtsev@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, sgoutham@cavium.com, rric@kernel.org,
        Radha.Chintakuntla@cavium.com
To: Vadim.Lomovtsev@caviumnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484234886-22172-1-git-send-email-Vadim.Lomovtsev@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vadim Lomovtsev <Vadim.Lomovtsev@caviumnetworks.com>
Date: Thu, 12 Jan 2017 07:28:06 -0800

> While probing BGX we requesting appropriate QLM for it's configuration
> and get LMAC count by that request. Then, while reading configured
> MAC values from SSDT table we need to save them in proper mapping:
>   BGX[i]->lmac[j].mac = <MAC value>
> to later provide for initialization stuff. In order to fill
> such mapping properly we need to add lmac index to be used while
> acpi initialization since at this moment bgx->lmac_count already contains
> actual value.
> 
> Signed-off-by: Vadim Lomovtsev <Vadim.Lomovtsev@caviumnetworks.com>

Applied.
