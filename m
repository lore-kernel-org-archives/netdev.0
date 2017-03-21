From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: stmmac still supporting spear600 ?
Date: Tue, 21 Mar 2017 15:50:54 +0100
Message-ID: <20170321155054.2f4cb921@free-electrons.com>
References: <20170309093412.33c0277d@free-electrons.com>
        <373e2760-94c5-4349-33aa-158bc8f4b19e@st.com>
        <20170309103236.3e16304f@free-electrons.com>
        <79049eda-5d37-6b70-8945-2d3ab55e56b8@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, Viresh Kumar <vireshk@kernel.org>,
        Shiraz Hashim <shiraz.linux.kernel@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:58048 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932333AbdCUOvL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 10:51:11 -0400
In-Reply-To: <79049eda-5d37-6b70-8945-2d3ab55e56b8@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, 9 Mar 2017 15:56:31 +0100, Giuseppe CAVALLARO wrote:

> On 3/9/2017 10:32 AM, Thomas Petazzoni wrote:
> 
> > OK, I'll have a look. However, I'm still confused by this DMA_RESET bit
> > that never clears, contrary to what the datasheet says. Are there some
> > erratas?  
> 
> I suggest you to take a look at the tx/rx clocks from PHY.
> You have to provide these otherwise you cannot reset the engine.

Thanks for the hint.

Further research has revealed that everything is working fine on a
platform with a Gigabit PHY connected via GMII.

However, on a different platform (which I'm using) with a 10/100 PHY
connected via MII, DMA_RESET never clears, and networking doesn't work.
The SMSC PHY LAN8700 is also supposed to be providing the clock through
its TX_CLK pin. I double checked, and both the MAC and PHY are in MII
mode, but still no luck so far.

Of course, if you have any suggestion or hint, I'm all ears :)

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
