From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 0/7] stmmac: update to Oct 2011 version (V2)
Date: Tue, 18 Oct 2011 10:44:58 +0200
Message-ID: <4E9D3C8A.50403@st.com>
References: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:46987 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756900Ab1JRIx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 04:53:57 -0400
In-Reply-To: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry this is the V3 :-(

Peppe

On 10/18/2011 10:42 AM, Giuseppe CAVALLARO wrote:
> This patches update the driver adding the chained
> descriptor mode and some new useful fixes.
> 
> I've reviewed some patches after the V1 and V2:
> 
>  stmmac: allow mtu bigger than 1500 in case of normal desc (V3)
>    |-> removed the useless max_mtu init: Thx Eric's feedback
> 
>  stmmac: add CHAINED descriptor mode support (V3)
>    |-> removed ifdef in the C and added small routines
> 	specialised for chained/ring modes. See comment
> 	within the patch itself. Thx David's feedback.
> 
>  stmmac: allow mmc usage only if feature actually available (V3)
>    |-> added a check if interface is NULL
> 
> In the end, I added two new small patches:
> 
>  stmmac: use predefined macros for HW cap register fields (V3)
>  stmmac: allow mmc usage only if feature actually available (V3)
> 
> made by Rayagond and reviewed/reworked by myself
> 
> Let me know if it's ok.
> 
> Giuseppe Cavallaro (5):
>   stmmac: protect tx process with lock (V3)
>   stmmac: update the driver version and doc (V3)
>   stmmac: allow mtu bigger than 1500 in case of normal desc (V3)
>   stmmac: allow mmc usage only if feature actually available (V3)
>   stmmac: add CHAINED descriptor mode support (V3)
> 
> Rayagond Kokatanur (1):
>   stmmac: use predefined macros for HW cap register fields (V3)
> 
> Srinivas Kandagatla (1):
>   stmmac: Stop advertising 1000Base capabilties for non GMII iface
>     (V3).
> 
>  Documentation/networking/stmmac.txt                |   11 +-
>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |   18 ++
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |    2 +
>  drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |  137 +++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/common.h       |   43 ++++
>  drivers/net/ethernet/stmicro/stmmac/descs_com.h    |  126 ++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   22 +--
>  drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   14 +-
>  drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |  126 ++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    5 +-
>  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   24 ++-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  212 ++++++++++----------
>  12 files changed, 602 insertions(+), 138 deletions(-)
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/chain_mode.c
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/descs_com.h
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> 
