From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac still supporting spear600 ?
Date: Thu, 9 Mar 2017 15:56:31 +0100
Message-ID: <79049eda-5d37-6b70-8945-2d3ab55e56b8@st.com>
References: <20170309093412.33c0277d@free-electrons.com>
 <373e2760-94c5-4349-33aa-158bc8f4b19e@st.com>
 <20170309103236.3e16304f@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shiraz Hashim <shiraz.linux.kernel@gmail.com>,
 Alexandre Torgue <alexandre.torgue@st.com>,
 linux-arm-kernel@lists.infradead.org, Viresh Kumar <vireshk@kernel.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170309103236.3e16304f@free-electrons.com>
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

Hello Thomas

On 3/9/2017 10:32 AM, Thomas Petazzoni wrote:

> OK, I'll have a look. However, I'm still confused by this DMA_RESET bit
> that never clears, contrary to what the datasheet says. Are there some
> erratas?

I suggest you to take a look at the tx/rx clocks from PHY.
You have to provide these otherwise you cannot reset the engine.

Best Regards
Peppe

>
> Best regards,
>
> Thomas
>
