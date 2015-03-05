From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: xgene: fix booting with devicetree
Date: Thu, 05 Mar 2015 15:40:28 -0500 (EST)
Message-ID: <20150305.154028.1720279992189151467.davem@davemloft.net>
References: <1425487917-19040-1-git-send-email-msalter@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fkan@apm.com, isubramanian@apm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: msalter@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425487917-19040-1-git-send-email-msalter@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Salter <msalter@redhat.com>
Date: Wed,  4 Mar 2015 11:51:57 -0500

> Commit de7b5b3d790a ("net: eth: xgene: change APM X-Gene SoC platform
> ethernet to support ACPI") breaks booting with devicetree with UEFI
> firmware. In that case, I get:
 ...
> The problem here is that the enet hw clocks are not getting
> initialized because of a test to avoid the initialization if
> UEFI is used to boot. This is an incorrect test. When booting
> with UEFI and devicetree, the kernel must still initialize
> the enet hw clocks. If booting with ACPI, the clock hw is
> not exposed to the kernel and it is that case where we want
> to avoid initializing clocks.
> 
> Signed-off-by: Mark Salter <msalter@redhat.com>

Applied, thanks Mark.
