From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 4/6 v2] IB: address translation to map IP toIB addresses (GIDs)
Date: Tue, 21 Mar 2006 12:57:24 -0800
Message-ID: <adabqvza53f.fsf@cisco.com>
References: <ORSMSX401FRaqbC8wSA0000000d@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<openib-general@openib.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965111AbWCUU51@vger.kernel.org>
To: "Sean Hefty" <sean.hefty@intel.com>
In-Reply-To: <ORSMSX401FRaqbC8wSA0000000d@orsmsx401.amr.corp.intel.com> (Sean Hefty's message of "Mon, 6 Mar 2006 15:31:58 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +struct workqueue_struct *rdma_wq;
 > +EXPORT_SYMBOL(rdma_wq);

Sean, I don't think I saw an answer when I asked you this before.  Why
is ib_addr exporting a workqueue?  Is there some sort of ordering
constraint that is forcing other modules to go through the same
workqueue for things?

This seems like a very fragile internal thing to be exposing, and I'm
wondering if there's a better way to handle it.

 - R.
