From: David Miller <davem@davemloft.net>
Subject: Re: [RFC Patch 2/3] bridge: make bridge support netpoll
Date: Mon, 22 Mar 2010 21:57:03 -0700 (PDT)
Message-ID: <20100322.215703.77339158.davem@davemloft.net>
References: <4BA82186.3010204@redhat.com>
	<1269318470.3552.54.camel@calx>
	<4BA84607.7030304@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BA84607.7030304@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Tue, 23 Mar 2010 12:39:35 +0800

> How could you let the bridge know netpoll is not sent to
> the one that doesn't support netpoll during setup? This will
> be complex, I am afraid.

Why does this matter at all?

I told you in another mail that we should do away with
these callbacks and all the crazy 'npinfo' assignments
and just do it in the generic code.
