From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Mon, 19 Mar 2007 09:10:16 -0600
Message-ID: <m1r6rlxo9z.fsf@ebiederm.dsl.xmission.com>
References: <20070318224234.GP11078@mellanox.co.il>
	<20070318.171337.112622504.davem@davemloft.net>
	<m3aby94x6o.fsf@maxwell.lnxi.com>
	<20070318.231316.59470365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070318.231316.59470365.davem@davemloft.net> (David Miller's
	message of "Sun, 18 Mar 2007 23:13:16 -0700 (PDT)")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:


> I think the thing to do is to just leave the loopback references
> in place, try to unregister the per-namespace loopback device,
> and that will safely wait for all the references to go away.

Right.  The only thing I have found that needs to be changed so
far in this area is specifying which loopback device I want
to replace it with.

> If you do it that way, you should need absolutely no changes to
> the other code in this area.
>
> As per Herbert, I think he works on Xen rather than vserver :-)
> Perhaps you're thinking of Alexey Kuznetsov or another one of the
> vserver guys.

I think you are thinking of a different Herbert.  I was thinking of
Herbert Poetzl the vserver maintainer.  Alexey works on OpenVZ.

Until we get the basic architecture merged they are rival projects.

Eric
