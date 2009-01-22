From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Thu, 22 Jan 2009 16:49:40 -0600
Message-ID: <4978F804.3060502@cs.wisc.edu>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com, tgraf@suug.ch,
	kkeil@suse.de, herbert@gondor.apana.org.au
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:39624 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502AbZAVXYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 18:24:45 -0500
In-Reply-To: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> 
> skb_copy_bits is an example of the code flow that does work.
> 
> skb_seq_read appears to only be used by iSCSI and the skb text match 
> support in tc/netfilter (aka skb_find_text)
> 

There is no reason iscsi needs to use skb_seq_read. It used to use 
skb_copy_bits. I can convert iscsi to use skb_copy_bits again.

Is it easier to just convert the text search to not use skb_seq_read, 
and then just dump those functions?
