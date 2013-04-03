From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next.git 2/7] stmmac: review barriers
Date: Wed, 03 Apr 2013 18:02:08 +0400
Message-ID: <515C3660.7000909@cogentembedded.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com> <1364967689-11155-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Deepak Sikri <deepak.sikri@st.com>,
	Shiraz Hashim <shiraz.hashim@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33229 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762599Ab3DCODH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 10:03:07 -0400
Received: by mail-lb0-f172.google.com with SMTP id u10so1627383lbi.31
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 07:03:06 -0700 (PDT)
In-Reply-To: <1364967689-11155-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03-04-2013 9:41, Giuseppe CAVALLARO wrote:

> In all my tests performed on SH4 and ARM A9 platforms, I've never met problems
> that can be fixed by using memory barriers. In the past there was some issues
> on SMP ARM but fixed by reviewing xmit spinlock.

> Further barriers have been added in the commits too: 8e83989106562326bf

    Please also specify that commit's summary line in parens.

> This patch is to use the smp_wbm instead of wbm because the driver

    It's "wmb".

> runs on UP systems. Then, IMO it could make sense to only maintain the barriers
> just in places where we touch the dma owner bits (that is the
> only real critical path as we had seen and fixed in the commit:
> eb0dc4bb2e22c04964d).

   This one's too.

> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Deepak Sikri <deepak.sikri@st.com>
> Cc: Shiraz Hashim <shiraz.hashim@st.com>

WBR, Sergei
