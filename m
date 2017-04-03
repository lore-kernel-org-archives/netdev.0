From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac still supporting spear600 ?
Date: Mon, 3 Apr 2017 08:16:50 +0200
Message-ID: <0468e2fb-5a7d-97ec-c51c-2436a13dda69@st.com>
References: <20170309093412.33c0277d@free-electrons.com>
 <373e2760-94c5-4349-33aa-158bc8f4b19e@st.com>
 <20170309103236.3e16304f@free-electrons.com>
 <79049eda-5d37-6b70-8945-2d3ab55e56b8@st.com>
 <20170321155054.2f4cb921@free-electrons.com>
 <63405ec5-099c-b935-2724-6c85012fc9f7@st.com>
 <20170402233028.60acf612@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shiraz Hashim <shiraz.linux.kernel@gmail.com>,
 Alexandre Torgue <alexandre.torgue@st.com>,
 linux-arm-kernel@lists.infradead.org, Viresh Kumar <vireshk@kernel.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170402233028.60acf612@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Thomas

I tested the SMSC on other platform (+ stmmac), not on SPEAr.

ok for reset, keep the radar on clock. Hmm, can you attach a piece of 
log file to see the failure?

Regards
Peppe

On 4/2/2017 11:30 PM, Thomas Petazzoni wrote:
> Hello,
>
> On Thu, 23 Mar 2017 11:33:23 +0100, Giuseppe CAVALLARO wrote:
>
>>> Further research has revealed that everything is working fine on a
>>> platform with a Gigabit PHY connected via GMII.
>>>
>>> However, on a different platform (which I'm using) with a 10/100 PHY
>>> connected via MII, DMA_RESET never clears, and networking doesn't work.
>>> The SMSC PHY LAN8700 is also supposed to be providing the clock through
>>> its TX_CLK pin. I double checked, and both the MAC and PHY are in MII
>>> mode, but still no luck so far.
>>>
>>> Of course, if you have any suggestion or hint, I'm all ears :)
>> I can just you to keep the focus on clock configuration. I tested the
>> SMSC PHY LAN8700
>> w/o any issues on several platform.  In MII both rx/tx_clk are provided
>> by PHY and if you
>> have an external oscillator this should be safe enough, indeed.
>> Another check you can do is about the reset time! Maybe you need to
>> change something
>> when reset the SMSC transceiver, try to increase the delay (if you use
>> GPIO to reset it).
> On which platform did you test with the LAN8700 PHY ? Was it on a
> SPEAr600 based platform ?
>
> If you tested on SPEAr600, what is the GMAC clock configuration (i.e
> the value of the GMAC_CFG_CTR and GMAC_CFG_SYNT registers) ?
>
> Regarding the PHY reset time, our PHY reset pin is not connected to a
> GPIO, but to the system reset logic, so Linux cannot reset the PHY with
> a GPIO.
>
> Thanks!
>
> Thomas
