From: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Subject: Re: [PATCH 03/13] stmmac: add the new Header file for stmmac platform
 data
Date: Thu, 07 Jan 2010 08:13:38 -0500
Message-ID: <4B45DE02.5010403@octasic.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.octasic.com ([70.54.254.106]:16714 "EHLO
	MAILEXCH.octasic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab0AGNNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 08:13:43 -0500
In-Reply-To: <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Giuseppe CAVALLARO wrote:
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  include/linux/stmmac.h |   53 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 53 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/stmmac.h
>
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> new file mode 100644
> index 0000000..32bfd1a
> --- /dev/null
> +++ b/include/linux/stmmac.h
>   
Coming to think of it, it might be preferable to locate this file in 
drivers/net/stmmac/stmmac_plat.h and have the platform-specific code do 
inclusions like: #include "../../../drivers/net/stmmac/stmmac_plat.h"

jh
