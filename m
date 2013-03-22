From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 0/9] stmmac: update to March_2013 (adding PTP &
 RGMII/SGMII)
Date: Fri, 22 Mar 2013 15:27:27 +0100
Message-ID: <514C6A4F.3020601@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com> <20130307.153456.83724032858548621.davem@davemloft.net> <51399048.3070505@st.com> <20130308.112219.1999774630969953487.davem@davemloft.net> <513D839A.8000009@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bh74.an@samsung.com,
	rayagond@vayavyalabs.com,
	Richard Cochran <richardcochran@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog121.obsmtp.com ([207.126.144.151]:34091 "EHLO
	eu1sys200aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933511Ab3CVOo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:44:57 -0400
In-Reply-To: <513D839A.8000009@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/11/2013 8:11 AM, Giuseppe CAVALLARO wrote:
[snip]
> At any case, I'll arrange to change the code removing the Koption and
> continuing (as done in the past) to setup at probe time the right
> configuration. This will be in the next version of the patches.

I've finally completed this task and I've reworked all the code to
completely remove the Koption (also for chain/ring mode).
Now all is done at probe time as discussed in this email thread.
On top of this, the PTP will be ported with Richard's advice
Pls let me know if there are other suggestions about the patches, I have
sent, so I can review and update them before resending the new versions.

peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
