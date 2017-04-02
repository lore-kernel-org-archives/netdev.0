From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: stmmac still supporting spear600 ?
Date: Sun, 2 Apr 2017 23:30:28 +0200
Message-ID: <20170402233028.60acf612@free-electrons.com>
References: <20170309093412.33c0277d@free-electrons.com>
        <373e2760-94c5-4349-33aa-158bc8f4b19e@st.com>
        <20170309103236.3e16304f@free-electrons.com>
        <79049eda-5d37-6b70-8945-2d3ab55e56b8@st.com>
        <20170321155054.2f4cb921@free-electrons.com>
        <63405ec5-099c-b935-2724-6c85012fc9f7@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, Viresh Kumar <vireshk@kernel.org>,
        Shiraz Hashim <shiraz.linux.kernel@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:46206 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751322AbdDBVaa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 17:30:30 -0400
In-Reply-To: <63405ec5-099c-b935-2724-6c85012fc9f7@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, 23 Mar 2017 11:33:23 +0100, Giuseppe CAVALLARO wrote:

> > Further research has revealed that everything is working fine on a
> > platform with a Gigabit PHY connected via GMII.
> >
> > However, on a different platform (which I'm using) with a 10/100 PHY
> > connected via MII, DMA_RESET never clears, and networking doesn't work.
> > The SMSC PHY LAN8700 is also supposed to be providing the clock through
> > its TX_CLK pin. I double checked, and both the MAC and PHY are in MII
> > mode, but still no luck so far.
> >
> > Of course, if you have any suggestion or hint, I'm all ears :)  
> 
> I can just you to keep the focus on clock configuration. I tested the 
> SMSC PHY LAN8700
> w/o any issues on several platform.  In MII both rx/tx_clk are provided 
> by PHY and if you
> have an external oscillator this should be safe enough, indeed.
> Another check you can do is about the reset time! Maybe you need to 
> change something
> when reset the SMSC transceiver, try to increase the delay (if you use 
> GPIO to reset it).

On which platform did you test with the LAN8700 PHY ? Was it on a
SPEAr600 based platform ?

If you tested on SPEAr600, what is the GMAC clock configuration (i.e
the value of the GMAC_CFG_CTR and GMAC_CFG_SYNT registers) ?

Regarding the PHY reset time, our PHY reset pin is not connected to a
GPIO, but to the system reset logic, so Linux cannot reset the PHY with
a GPIO.

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
