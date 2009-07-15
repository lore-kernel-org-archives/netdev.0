From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] veth: don't free priv->status until
 dev->destructor (v2)
Date: Wed, 15 Jul 2009 08:50:12 -0700 (PDT)
Message-ID: <20090715.085012.223420354.davem@davemloft.net>
References: <20090626162418.GA24828@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, containers@lists.osdl.org,
	sachinp@in.ibm.com, netdev@vger.kernel.org, matthltc@us.ibm.com,
	linux-kernel@vger.kernel.org
To: serue@us.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755562AbZGOPuK@vger.kernel.org>
In-Reply-To: <20090626162418.GA24828@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Serge E. Hallyn" <serue@us.ibm.com>
Date: Fri, 26 Jun 2009 11:24:18 -0500

> I haven't been able to reproduce the original oops though (been
> trying to cat the stats sysfs files while rmmoding veth, to no
> avail, and haven't found an original bug report or testcase), so
> can't verify whether this patch prevents the original oops.

If you 'cat' it you're unlikely to trigger the oops.

You have to hold the sysfs files open, and then elsewhere do the
rmmod, wait, and then continue with some access to those open sysfs
file descriptors (f.e. do some reads).

I'd also need this patch to be against current sources as they'll
never apply since I did the revert quite some time ago.

Thanks.
