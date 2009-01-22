From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Thu, 22 Jan 2009 15:45:16 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1BEF93EC@orsmsx507.amr.corp.intel.com>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com>
 <20090122232131.GA22771@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@suug.ch" <tgraf@suug.ch>, "kkeil@suse.de" <kkeil@suse.de>,
	"michaelc@cs.wisc.edu" <michaelc@cs.wisc.edu>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50085 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755272AbZAVXpX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 18:45:23 -0500
In-Reply-To: <20090122232131.GA22771@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 22, 2009 at 12:55:21PM -0800, Brandeburg, Jesse wrote:
>> I've filed this bugzilla a while ago.
>> http://bugzilla.kernel.org/show_bug.cgi?id=11804
>> now other customers are becoming interested as well
> 
> Does this patch help?
> 
> net: Fix frag_list handling in skb_seq_read
> 
> The frag_list handling was broken ini skb_seq_read:
> 
> 1) We didn't add the stepped offset when looking at the head
> are of fragments other than the first.
> 
> 2) The frag index wasn't reset.
> 
> This patch fixes both issues.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Herbert, thanks! the patch looks promsing, but we have to setup the repro again.
I'll have a tester take a look at it tomorrow or Monday, and let you know then.

Thanks!
  Jesse