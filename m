From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 1/2] workqueue: convert
 cancel_rearming_delayed_work[queue]() users to cancel_delayed_work_sync()
Date: Wed, 15 Dec 2010 00:24:35 +0300
Message-ID: <20101214212435.GA10097@ioremap.net>
References: <4D078B6D.5060202@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	benh@kernel.crashing.org, mchehab@infradead.org,
	davem@davemloft.net, netdev@vger.kernel.org, cbou@mail.ru,
	dwmw2@infradead.org, gregkh@suse.de, bfields@fieldses.org,
	neilb@suse.de, aelder@sgi.com, xfs-masters@oss.sgi.com,
	cl@linux-foundation.org, penberg@cs.helsinki.fi,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D078B6D.5060202@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Tue, Dec 14, 2010 at 04:21:17PM +0100, Tejun Heo (tj@kernel.org) wrote:
> cancel_rearming_delayed_work[queue]() has been superceded by
> cancel_delayed_work_sync() quite some time ago.  Convert all the
> in-kernel users.  The conversions are completely equivalent and
> trivial.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: Evgeniy Polyakov <zbr@ioremap.net>

-- 
	Evgeniy Polyakov
