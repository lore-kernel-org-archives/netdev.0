From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Tue, 02 Oct 2007 11:26:53 -0700
Message-ID: <adaprzxgyoi.fsf@cisco.com>
References: <adahclymos8.fsf@cisco.com>
	<000401c7f632$c993e8e0$65cc180a@amr.corp.intel.com>
	<adatzpyl1mm.fsf@cisco.com>
	<000001c7f6f7$074584e0$9c98070a@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "Sean Hefty" <sean.hefty@intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <000001c7f6f7$074584e0$9c98070a@amr.corp.intel.com> (Sean Hefty's
	message of "Fri, 14 Sep 2007 10:45:23 -0700")
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

 > >OK -- just to make sure I'm understanding what you're saying: have you
 > >confirmed that your proposed [CM MRA] patches actually fix the issue?
 > 
 > Not directly.  I cannot easily test kernel patches on our larger, production
 > clusters.  We've seen the issue with specific applications on 512 and 1024
 > cores, but I've only been able to test the patch on a 48-core cluster.  I have
 > verified that it successfully increases the timeout to where it *should* work,
 > but cannot absolutely confirm that it will fix the problem.  I'm unlikely to
 > know that until the production clusters move to an OFED release (1.3?)
 > containing this patch.

Umm... this is a difficult situation for me to merge the changes then.
We're changing the CM retry behavior blind here.  How do we know that
the MRA changes don't make the scalability issue worse?

 - R.
