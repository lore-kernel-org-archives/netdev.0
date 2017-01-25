From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: stmmac: GMAC_RGSMIIIS reports bogus values
Date: Wed, 25 Jan 2017 10:47:56 -0800
Message-ID: <c327164e-e544-ecd8-3501-44e68942b725@synopsys.com>
References: <1478189833.4072.65.camel@synopsys.com>
 <a1f114cc-6120-154c-a3f7-3e0389d38e36@st.com>
 <1485369563.7117.81.camel@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "manabian@gmail.com" <manabian@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "fabrice.gasnier@st.com" <fabrice.gasnier@st.com>,
        "linux-snps-arc@lists.infradead.org"
        <linux-snps-arc@lists.infradead.org>,
        "alexandre.torgue@gmail.com" <alexandre.torgue@gmail.com>,
        "preid@electromag.com.au" <preid@electromag.com.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
        "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485369563.7117.81.camel@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/25/2017 10:39 AM, Alexey Brodkin wrote:
>> Also I wonder if, other version of the stmmac worked on this platform
>> before.
> It did work and still works. The only problem is we're getting
> a lot of noise now about bogus link status change. That's because
> this info is now in pr_info() compared to being previously in pr_debug().

While we sort out the real technical details, it is OK to go back to pr_debug
please - print_once or some such !
There is lot of useless console noise when we run any networking loads here !

echo 0 >  /proc/sys/kernel/printk

only helps in that it is not printed on console but clobbers dmesg nonetheless !

Thx,
-Vineet
