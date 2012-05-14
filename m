From: David Miller <davem@davemloft.net>
Subject: Re: [patch] netfilter: potential NULL dereference in
 get_inner_hdr()
Date: Mon, 14 May 2012 03:38:53 -0400 (EDT)
Message-ID: <20120514.033853.1089019132135043947.davem@davemloft.net>
References: <20120512110003.GB19472@elgon.mountain>
	<201205140936.56960.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: hans.schillstrom@ericsson.com
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <201205140936.56960.hans.schillstrom@ericsson.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date: Mon, 14 May 2012 09:36:55 +0200

> On Saturday 12 May 2012 13:00:03 Dan Carpenter wrote:
>> There is a typo in the error checking and "&&" was used instead of "||".
>> If skb_header_pointer() returns NULL then it leads to a NULL
>> dereference.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> Ack-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
>  
>> ---
>> Btw, this is new code and Sparse complains about endian bugs.
> 
> Can you give me some hints here, arch , compiler version etc.
> I guess it was input to hmark_addr_mask() that complains ?

He said what he's using, "sparse", the semantic parser, which
is largely arch agnostic.

I guarantee you will see the warnings if you run it on your
system on this code.


