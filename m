From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH (sh-2.6) 1/4] clksource: Generic timer infrastructure
Date: Tue, 1 Mar 2011 21:41:26 +0100
Message-ID: <201103012141.26679.arnd@arndb.de>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com> <201103011743.19847.arnd@arndb.de> <20110301202611.GC27107@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stuart Menefy <stuart.menefy@st.com>,
	Peppe CAVALLARO <peppe.cavallaro@st.com>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Russell King - ARM Linux" <linux@arm.linux.org.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20110301202611.GC27107@n2100.arm.linux.org.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 01 March 2011 21:26:11 Russell King - ARM Linux wrote:
> On Tue, Mar 01, 2011 at 05:43:19PM +0100, Arnd Bergmann wrote:
> > On Tuesday 01 March 2011, Stuart Menefy wrote:
> > > On 24/02/11 17:20, Arnd Bergmann wrote:
> > > > Also, what is the difference between this and clkdev?
> > > 
> > > clkdev can be used to find a struct clk, which is fine if you just want to
> > > read the time. In this instance we want to get interrupts from the timer
> > > hardware, which isn't supported by the clk infrastructure.
> > 
> > (adding Russell to Cc)
> > 
> > Is this something that could sensibly be added to clk/clkdev?
> 
> I don't understand - why would anyone want to use clk/clkdev for timers.
> clk/clkdev is all about those signals on the SoC which wiggle at regular
> intervals between logic 0 and logic 1.  It's not about things which count,
> which seems to be an entirely separate problem, and hence why there's
> nothing to deal with interrupts or setting timeouts etc.

Ok, I see. I had mixed the two concepts. The clkdev infrastructure
seemed like a nice way to connect a source and a consumer of a timer,
but you're right that it's an entirely separate thing, and as Thomas
said, it's probably not needed either.

	Arnd
