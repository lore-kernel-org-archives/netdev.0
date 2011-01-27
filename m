From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH V10 01/15] time: Introduce timekeeping_inject_offset
Date: Thu, 27 Jan 2011 10:48:19 -0800
Message-ID: <1296154099.2855.162.camel@work-vm>
References: <cover.1296124770.git.richard.cochran@omicron.at>
	 <6aec014551fc1d34924d6a7bcf97769867c15ba9.1296124770.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Mike Frysinger <vapier@gentoo.org>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@arm.linux.org.uk>
To: Richard Cochran <richardcochran@gmail.com>,
	Richard Cochran <richard.cochran@omicron.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6aec014551fc1d34924d6a7bcf97769867c15ba9.1296124770.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-01-27 at 11:54 +0100, John Stultz wrote:
> This adds a kernel-internal timekeeping interface to add or subtract
> a fixed amount from CLOCK_REALTIME. This makes it so kernel users or
> interfaces trying to do so do not have to read the time, then add an
> offset and then call settimeofday(), which adds some extra error in
> comparision to just simply adding the offset in the kernel timekeeping
> core.
> 
> CC: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---


Hey Richard,
	Something seems wrong with your mail sending script. It looks like your
sending the email under my name (John Stultz
<richardcochran@gmail.com>).

While I appreciate you preserving the path author, and the signoffs are
right, you really should send the email under your own name.

The proper style is to keep the mail-header From: the same (ie: Richard
Cochran <richardcochran@gmail.com>), but as the first line of the mail
body put:
   From: Author Name <author@lemail.com>

thanks
-john
