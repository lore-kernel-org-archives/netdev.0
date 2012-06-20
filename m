From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 02:58:37 -0700 (PDT)
Message-ID: <20120620.025837.721158723130014230.davem@davemloft.net>
References: <3170667.1PZa2330KE@harkonnen>
	<20120620.020611.1696375957120854262.davem@davemloft.net>
	<5059693.iaLYtpk3E4@harkonnen>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, bhupesh.sharma@st.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, giancarlo.asnaghi@st.com,
	wg@grandegger.com
To: federico.vaga@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <5059693.iaLYtpk3E4@harkonnen>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Federico Vaga <federico.vaga@gmail.com>
Date: Wed, 20 Jun 2012 11:59:26 +0200

>> Then the driver should NEVER have been submitted without the
>> required infrastructure in place first.
> 
> This particular driver don't use the clk framework at the moment. I put 
> that lines about clk to try to be generic as possibile, but I see that I 
> made a mistake: I'm sorry.

Why would you try to be generic by using an interface currently
only available on certain platforms?

That is how you make drivers non-portable, and not generic.
