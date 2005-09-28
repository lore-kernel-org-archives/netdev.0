From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Wed, 28 Sep 2005 10:37:02 +0200
Message-ID: <200509281037.03185.ak@suse.de>
References: <432EF0C5.5090908@cosmosbay.com>
	<Pine.LNX.4.61.0509280219110.25500@filer.marasystems.com>
	<20050928083240.GP4168@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, Henrik Nordstrom <hno@marasystems.com>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050928083240.GP4168@sunbeam.de.gnumonks.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Wednesday 28 September 2005 10:32, Harald Welte wrote:

> I totally agree, that from a current perspective, I think the concept of
> just loading a module (that has usage count 0) having severe impact on
> system performance is just wrong.  But then, users are used to the
> current behaviour for almost five years now. 

That doesn't mean it cannot be improved - and I think it should.

In a sense it's even getting worse: For example us losing the CONFIG
option to disable local conntrack (Patrick has disabled it some time ago 
without even a comment why he did it) has a really bad impact in some cases.

> Therefore: Let's do this right next time, but live with that fact for
> now.

Even with a "quite straight-forward" (quoting you) fix?

> Just imagine all those poor sysadmins who know nothing about current
> kernel development, and who upgrade their kernel because their
> distributor provides a new one - suddenly their accounting (which might
> be relevant for their business) doesn't work anymore :(

Accounting with per CPU counters can be done fully lockless.

-Andi
