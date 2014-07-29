From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Subject: RE: [PATCH] bnx2x: Add FW 7.10.51
Date: Tue, 29 Jul 2014 11:28:54 +0000
Message-ID: <87B4DDAD5EAFA041BDC28F314593782D0180D6D0@avmb3.qlogic.org>
References: <1406145094-27383-1-git-send-email-dkravkov@lb-tlvb-dmitry.il.qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mintzyuval@gmail.com" <mintzyuval@gmail.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Dmitry Kravkov <dkravkov@gmail.com>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:54571 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753227AbaG2L3h convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 07:29:37 -0400
In-Reply-To: <1406145094-27383-1-git-send-email-dkravkov@lb-tlvb-dmitry.il.qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Dmitry Kravkov
> Sent: Wednesday, July 23, 2014 10:52 PM
> To: dwmw2@infradead.org; ben@decadent.org.uk; netdev
> Cc: mintzyuval@gmail.com; eric.dumazet@gmail.com; David Miller; Yuval
> Mintz; Dmitry Kravkov; Ariel Elior
> Subject: [PATCH] bnx2x: Add FW 7.10.51
> 
> From: Yuval Mintz <Yuval.Mintz@qlogic.com>
> 
> Hi,
> 
> This firmware includes many fixes such as:
> 
>  - (L2) In some multi-function configurations, inter-PF and inter-VF
>    Tx switching is incorrectly enabled.
> 
>  - (L2) Wrong assert code in FLR final cleanup in case it is sent not
>    after FLR.
> 
>  - (L2) Chip may stall in very rare cases under heavy traffic with FW GRO
>    enabled.
> 
>  - (L2) VF malicious notification error fixes.
> 
>  - (L2) Default gre tunnel to IPGRE which allows proper RSS for IPGRE
> packets,
>    L2GRE traffic will reach single queue.
> 
>  - (FCoE) Fix data being placed in wrong buffer when corrupt FCoE frame is
>    received.
> 
>  - (FCoE) Burst of FIP packets with destination MAC of ALL-FCF_MACs
>    causes FCoE traffic to stop.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
> ---
> Hi,
> 
> Please consider taking this FW.
> 
> Thanks,
> Yuval
> ---
>  WHENCE                       |   3 +++
>  bnx2x/bnx2x-e1-7.10.51.0.fw  | Bin 0 -> 164392 bytes
>  bnx2x/bnx2x-e1h-7.10.51.0.fw | Bin 0 -> 173016 bytes
>  bnx2x/bnx2x-e2-7.10.51.0.fw  | Bin 0 -> 321456 bytes
>  4 files changed, 3 insertions(+)
>  create mode 100644 bnx2x/bnx2x-e1-7.10.51.0.fw
>  create mode 100644 bnx2x/bnx2x-e1h-7.10.51.0.fw
>  create mode 100644 bnx2x/bnx2x-e2-7.10.51.0.fw

Any news about this? Thanks. Dmitry 
