From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V7 4/8] posix clocks: hook dynamic clocks into system
 calls
Date: Tue, 21 Dec 2010 09:00:37 +0100
Message-ID: <20101221080037.GB13626@riccoc20.at.omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <6241238a1df55033e50b151ec9d35ba957e43d53.1292512461.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1012162156580.12146@localhost6.localdomain6>
 <20101217070450.GB2982@riccoc20.at.omicron.at>
 <alpine.LFD.2.00.1012171010160.12146@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1012171010160.12146@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 17, 2010 at 11:03:46AM +0100, Thomas Gleixner wrote:
> 
> Doesn't the same problem exist for the file operations of patch 3? I
> think you want the very same protection there unless you want to do
> the same magic in your USB driver as well.

Yes, you are right. I overlooked that.

> So you could do the following:
  ...

> So your fops would call get_fd_clk() and put_fd_clk() and the pc_timer
> ones get_posix_clock() and put_posix_clock() or whatever sensible
> function names you come up with.
> 
> Thoughts ?

It is a good, concrete suggestion. I will try it that way.

Thanks,

Richard
