From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] stmmac: Update stmmac descriptor checks for stmmac
 core prior to Rev-3.5.
Date: Sun, 04 Mar 2012 20:51:55 -0500 (EST)
Message-ID: <20120304.205155.650947216183181836.davem@davemloft.net>
References: <1330692928-30330-3-git-send-email-deepak.sikri@st.com>
	<1330692928-30330-4-git-send-email-deepak.sikri@st.com>
	<1330692928-30330-5-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, spear-devel@list.st.com,
	netdev@vger.kernel.org
To: deepak.sikri@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314Ab2CEBwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 20:52:03 -0500
In-Reply-To: <1330692928-30330-5-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Sikri <deepak.sikri@st.com>
Date: Fri, 2 Mar 2012 18:25:26 +0530

> +static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err,
> +		u32 mac_id)

Poorly formatted, this should be:

static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err,
			      u32 mac_id)


> +			/*
> +			 * The type-1 checksume offload engines append
> +			 * the checksum at the end of frame, and the

	/* Format comments
	 * like this.
	 */

	/*
	 * Not
	 * like this.
	 */
