From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: linux-4.2-rc2/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1993:
 possible bad error checking ?
Date: Tue, 14 Jul 2015 08:10:28 +0200
Message-ID: <55A4A7D4.9000405@st.com>
References: <DUB128-W847EC851814161BB5A100A9C9C0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: David Binderman <dcb314@hotmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:33097 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751924AbbGNGKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 02:10:35 -0400
In-Reply-To: <DUB128-W847EC851814161BB5A100A9C9C0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David

thx to have looked at this. I'll check the code and eventually fix it, 
unless you already have a patch to propose.

Kind Regards
Peppe

On 7/13/2015 11:48 AM, David Binderman wrote:
> Hello there,
>
> [linux-4.2-rc2/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1993]: (style) Checking if unsigned variable 'entry' is less than zero.
>
> Source code is
>
>          entry = priv->hw->mode->jumbo_frm(priv, skb, csum_insertion);
>          if (unlikely(entry < 0))
>              goto dma_map_err;
>
> but
>
>      unsigned int entry;
>
> So the error checking from the function call looks broken to me.
>
> If the return value from the function call to jumbo_frm is a plain signed integer, suggest
> sanity check that *before* assigning into an unsigned integer.
>
> Regards
>
> David Binderman
>
>   		 	   		
>
