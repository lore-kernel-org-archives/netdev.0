From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: Re: SACK performance improvements - technical report and
	updated 2.6.6 patches
Date: Mon, 19 Dec 2005 21:11:40 -0500
Message-ID: <200512200213.jBK2DbJl019826@uni03mr.unity.ncsu.edu>
References: <20051219.132256.61038824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, end2end-interest@postel.org,
   d.leith@eee.strath.ac.uk
Return-path: <end2end-interest-bounces@postel.org>
To: "'David S. Miller'" <davem@davemloft.net>, <baruch@ev-en.org>
In-Reply-To: <20051219.132256.61038824.davem@davemloft.net>
List-Unsubscribe: <http://www.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=unsubscribe>
List-Archive: <http://www.postel.org/pipermail/end2end-interest>
List-Post: <mailto:end2end-interest@postel.org>
List-Help: <mailto:end2end-interest-request@postel.org?subject=help>
List-Subscribe: <http://www.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=subscribe>
Sender: end2end-interest-bounces@postel.org
Errors-To: end2end-interest-bounces@postel.org
List-Id: netdev.vger.kernel.org

I wonder the same. I wonder how this new patch by the HTCP folks
improves what we provided for the 2.6.x (which is currently
incorporated in the latest linux version). My recollection says that
this HTCP patch periodically crashes the system very often -- so we
could not run the comparison. BTW, this fast SACK path fix we provided
are just a simple clean-up and modification from the original Tom
Kelly's SACK code - so Tom deserves the full credit for it.


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David S. Miller
> Sent: Monday, December 19, 2005 4:23 PM
> To: baruch@ev-en.org
> Cc: netdev@vger.kernel.org; end2end-interest@postel.org;
> d.leith@eee.strath.ac.uk
> Subject: Re: SACK performance improvements - technical report and
> updated 2.6.6 patches
> 
> From: Baruch Even <baruch@ev-en.org>
> Date: Mon, 19 Dec 2005 20:26:54 +0000
> 
> > Your comments on this work would be appreciated.
> 
> Ummm... how about the patches that fix this which are in the 2.6.x
> kernel already?
> 
> Yes, it's not your stuff, but it was incredibly less invasive and
> probably works nearly as well.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
