From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Sat, 09 Aug 2008 22:14:11 -0700
Message-ID: <adavdy9zc2k.fsf@cisco.com>
References: <200808071145.03848.divy@chelsio.com>
	<489C8BEB.8060001@opengridcomputing.com> <489CC58D.4010606@pobox.com>
	<20080809.002840.167363463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, swise@opengridcomputing.com, divy@chelsio.com,
	kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080809.002840.167363463.davem@davemloft.net> (David Miller's
	message of "Sat, 09 Aug 2008 00:28:40 -0700 (PDT)")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Also, I find it ironic that the port abduction is being asked for in
 > order to be "compatible with existing tools" yet in fact this stuff
 > breaks everything.  You can't netfilter this traffic, you can't apply
 > qdiscs to it, you can't execut TC actions on them, you can't do
 > segmentation offload on them, you can't look for the usual TCP MIB
 > statistics on the connection, etc. etc. etc.

We already support offloads that break other features, eg large receive
offload breaks forwarding.  We deal with it.

I'm sure if we thought about it we could come up with clean ways to fix
some of the issues you raise, and just disable the offload if someone
wanted to use a feature we can't support.

 - R.
