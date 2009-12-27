From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Sun, 27 Dec 2009 10:22:38 -0800
Message-ID: <20091227102238.0df149f9@nehalam>
References: <4B300A2A.8040305@gmail.com>
	<4B300E30.9090707@majjas.com>
	<4B3114E3.1070602@majjas.com>
	<4B329FA3.9090904@majjas.com>
	<20091223230102.4bb0100e.akpm@linux-foundation.org>
	<4B34E847.8010809@majjas.com>
	<20091225152200.1cf11dfe@nehalam>
	<4B3581C7.8000702@majjas.com>
	<20091226095723.7ac82b18@nehalam>
	<4B367409.5060202@majjas.com>
	<4B379378.4000102@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751047AbZL0SXl@vger.kernel.org>
In-Reply-To: <4B379378.4000102@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 27 Dec 2009 12:03:52 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> Just an FYI - I left stuff running overnight and saw lots of this this 
> AM... ans one from last night:
> Dec 26 21:39:54 mail kernel: sky2 0000:06:00.0: error interrupt 
> status=0x40000008
> Dec 27 05:09:39 mail kernel: sky2 0000:06:00.0: error interrupt 
> status=0x40000008

You have hardware/firmware problem, that is beyond the driver.
That status indicates:
  Parity Error/MAC - "This interrupt is intended to indicate a panic event (hardware fault)"

What is your hardware configuration (lspci, kernel config, memory, cpu)?
