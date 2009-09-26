From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] cxgb3/cxgb3i: added support of private MAC
 address and provisioning packet handler for iSCSI
Date: Sat, 26 Sep 2009 00:16:46 -0700 (PDT)
Message-ID: <20090926.001646.06991481.davem@davemloft.net>
References: <200909252225.n8PMPaqI031748@localhost.localdomain>
	<20090925.152430.119503066.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334066E7019@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michaelc@cs.wisc.edu, James.Bottomley@HansenPartnership.com,
	swise@opengridcomputing.com, divy@chelsio.com, rakesh@chelsio.com,
	linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: kxie@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <8A71B368A89016469F72CD08050AD334066E7019@maui.asicdesigners.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Karen Xie" <kxie@chelsio.com>
Date: Fri, 25 Sep 2009 15:34:22 -0700

> Hmm, I am wondering how could this merge activity to be coordinated? If
> only the driver/scsi change is merged, then it won't compile either,
> since it requires the driver/net change.

That's rediculious, frankly.

Since they are two seperate changes you are knowingly creating
a bisection point that will not work.  That's wrong.

You need to split up the changes so that each and every one of them
are independant and the tree can be checked out at either of them and
everything can be expected to work.
