From: Alessandro Rubini <rubini@gnudd.com>
Subject: Re: [PATCH 0/3] stmmac patches
Date: Tue, 24 Jan 2012 21:47:10 +0100
Message-ID: <20120124204710.GA29113@mail.gnudd.com>
References: <20120124.154311.1857537203481263793.davem@davemloft.net>
  <cover.1327394750.git.rubini@gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, giancarlo.asnaghi@st.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120124.154311.1857537203481263793.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> The second patch is a cleanup, already acked by both authors.
> 
> I'm not applying this, instead if you want to make changes in this
> area then fix this driver so that it can properly support multiple
> device instances.

Ok, I'll do, but not soon.
 
> I can't even imagine ever writing a driver where from the start
> it can handle only one device instance, this is pure insanity
> especially for a PCI device driver.

I agree. But it _already_ is like this. I just want the fact to be
clear, so when somebody burns two macs in the fpga it will complain
instead of breaking.   That said, I have no problem if you still
refuse it.

> You're breaking things for anyone using 'stmmaceth='.  So I'm not
> applying this patch either.

Fine with me.

thanks
/alessandro
