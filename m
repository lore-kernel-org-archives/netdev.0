From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] Documentation: rw_lock lessons learned
Date: Thu, 12 Nov 2009 09:04:10 -0800
Message-ID: <20091112090410.43f90569@nehalam>
References: <4AF9C540.5090403@gmail.com>
	<20091110180646.2e5859a8@nehalam>
	<4AFAEF78.4080807@gmail.com>
	<20091111093724.4f40a48d@nehalam>
	<4AFBEC44.9030409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753628AbZKLREn@vger.kernel.org>
In-Reply-To: <4AFBEC44.9030409@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Nov 2009 06:06:44 -0500
William Allen Simpson <william.allen.simpson@gmail.com> wrote:

> +   NOTE! We are working hard to remove reader-writer spinlocks from the
> +   network stack, so please don't add a new one.  (Instead, see
> +   Documentation/RCU/rcu.txt for complete information.)

It is not just networking, so don't single that out.

Also, should mention -RT kernel and locking here (Appendix?)


-- 
