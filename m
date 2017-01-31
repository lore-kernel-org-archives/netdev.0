From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac: GMAC_RGSMIIIS reports bogus values
Date: Tue, 31 Jan 2017 10:55:18 +0100
Message-ID: <28d0ab2c-eb68-a520-e59a-83b15700fe44@st.com>
References: <1478189833.4072.65.camel@synopsys.com>
 <a1f114cc-6120-154c-a3f7-3e0389d38e36@st.com>
 <1485369563.7117.81.camel@synopsys.com>
 <1485512586.2693.35.camel@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "fabrice.gasnier@st.com" <fabrice.gasnier@st.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "manabian@gmail.com" <manabian@gmail.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "preid@electromag.com.au" <preid@electromag.com.au>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "alexandre.torgue@gmail.com" <alexandre.torgue@gmail.com>,
 "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>,
 Vineet Gupta <Vineet.Gupta1@synopsys.com>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
In-Reply-To: <1485512586.2693.35.camel@synopsys.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 1/27/2017 11:23 AM, Alexey Brodkin wrote:
> That's why my initial proposal was to ignore whatever we read from this register
> if we have MDIO bus instantiated already.

sorry for my late reply, I agree with this approach, according to the
HW and platform configuration the driver has to understand and then
work to use either SMA or PCS module.

Regards
Peppe
