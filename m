From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net-next v3] bnxt_en: New Broadcom ethernet driver.
Date: Tue, 20 Oct 2015 16:13:26 -0400
Message-ID: <20151020201326.GF23569@tuxdriver.com>
References: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, prashant@broadcom.com, eddie.wai@broadcom.com,
	huangjw@broadcom.com, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44762 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbbJTUPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 16:15:16 -0400
Content-Disposition: inline
In-Reply-To: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 17, 2015 at 12:21:44AM -0400, Michael Chan wrote:
> Broadcom ethernet driver for the new family of NetXtreme-C/E
> ethernet devices.
> 
> v3:
>   - Fixed 2 more sparse warnings.
>   - Removed some unused structures in .h files.
> 
> v2:
>   - Fixed all kbuild test robot reported warnings.
>   - Fixed many of the checkpatch.pl errors and warnings.
>   - Fixed the Kconfig description.
> 
> Acked-by: Eddie Wai <eddie.wai@broadcom.com>
> Acked-by: Jeffrey Huang <huangjw@broadcom.com>
> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/Kconfig              |   19 +
>  drivers/net/ethernet/broadcom/Makefile             |    1 +
>  drivers/net/ethernet/broadcom/bnxt/Makefile        |    4 +
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c          | 5821 ++++++++++++++++++++
>  drivers/net/ethernet/broadcom/bnxt/bnxt.h          |  994 ++++
>  drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c  | 1150 ++++
>  drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h  |   18 +
>  drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h   |  104 +
>  drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h      | 4046 ++++++++++++++
>  drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h |   59 +
>  drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c    |  787 +++
>  drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h    |   22 +
>  12 files changed, 13025 insertions(+)
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/Makefile
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt.c
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt.h
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h

Well, it's a big one!  But overall I'd say it looks pretty good...

I agree with Stephen's style comments, and there are a couple of
strings that are crazy long -- not just a source readability problem,
but things that would be hard to digest in a log as well.  If you
address those then I'll be happy to ACK it.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
