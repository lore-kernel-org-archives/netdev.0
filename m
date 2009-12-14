From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3] Documentation: rw_lock lessons learned
Date: Mon, 14 Dec 2009 09:50:06 -0800
Message-ID: <20091214095006.5cfc57a0@nehalam>
References: <4B254ABE.9040002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Clark <sclark46@earthlink.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932326AbZLNRuf@vger.kernel.org>
In-Reply-To: <4B254ABE.9040002@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 13 Dec 2009 15:12:46 -0500
William Allen Simpson <william.allen.simpson@gmail.com> wrote:

> In recent months, two different network projects erroneously
> strayed down the rw_lock path.  Update the Documentation
> based upon comments by Eric Dumazet and Paul E. McKenney in
> those threads.
> 
> Further updates await somebody else with more expertise.
> 
> Changes:
>   - Merged with extensive content by Stephen Hemminger.
>   - Fix one of the comments by Linus Torvalds.
> 
> Signed-off-by: William.Allen.Simpson@gmail.com
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
>   Documentation/spinlocks.txt |  184 ++++++++++++++++++++-----------------------
>   1 files changed, 84 insertions(+), 100 deletions(-)

The whole document needs a writer to go over it and make it readable.
Something like an updated chapter on locking from LDD3 book.
John? Randy?
