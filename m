From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: stmmac still supporting spear600 ?
Date: Thu, 9 Mar 2017 10:32:36 +0100
Message-ID: <20170309103236.3e16304f@free-electrons.com>
References: <20170309093412.33c0277d@free-electrons.com>
        <373e2760-94c5-4349-33aa-158bc8f4b19e@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, Viresh Kumar <vireshk@kernel.org>,
        Shiraz Hashim <shiraz.linux.kernel@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:59151 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752458AbdCIJcu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 04:32:50 -0500
In-Reply-To: <373e2760-94c5-4349-33aa-158bc8f4b19e@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Giuseppe,

Thanks for your answer.

On Thu, 9 Mar 2017 10:09:02 +0100, Giuseppe CAVALLARO wrote:

> We do not test stmmac on this spear board since many years
> and I guess you have to provide parameters from the platform.

Ok, that's what I was afraid of :-/

> In fact, stmmac is recently tested with DT.

I'm also using the DT, so this is definitely not the problem.

> IIRC, the mac on spear600 could not have the HW cap register

Correct.

> so it is mandatory to provide all the right parameters and
> configurations for this HW.

OK, I'll have a look. However, I'm still confused by this DMA_RESET bit
that never clears, contrary to what the datasheet says. Are there some
erratas?

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
