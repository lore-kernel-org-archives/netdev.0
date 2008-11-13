From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] net: Convert TCP & DCCP hash tables to use RCU /
 hlist_nulls
Date: Thu, 13 Nov 2008 08:08:18 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0811130805530.19293@quilx.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>
 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>
  <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>
  <4909D551.9080309@cosmosbay.com>  <491C2873.60004@cosmosbay.com>
 <1226583265.7685.4797.camel@twins> <491C30F5.4070904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Corey Minyard <minyard@acm.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi053.sbcis.sbc.com ([207.115.36.82]:59663 "EHLO
	nlpi053.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbYKMOTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 09:19:43 -0500
In-Reply-To: <491C30F5.4070904@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Nov 2008, Eric Dumazet wrote:

> So yes, this bit should be documented, since SLAB_DESTROY_BY_RCU is
> not really used in linux kernel at this moment.

It is used for the anonymous vmas. That is the purpose that Hugh
introduced it for since he saw regression if he would use straight rcu
freeing. See mm/rmap.c. SLAB_DESTROY_BY_RCU a pretty strange way of
using RCU and slab so it should always be documented in detail.

