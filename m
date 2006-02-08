From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Thu, 9 Feb 2006 10:26:58 +1100
Message-ID: <17386.32322.548974.883642@cargo.ozlabs.ibm.com>
References: <E1F6xei-0006hc-00@gondolin.me.apana.org.au>
	<OF71FA79DA.C4F20DA5-ON8825710F.007B701A-8825710F.007CB97E@us.ibm.com>
	<20060208232214.GC14543@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Carlson <carlsonj@workingcode.com>,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060208232214.GC14543@mipter.zuzino.mipt.ru>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan writes:

> The fact that they can be represented by the same bit patterns is
> irrelevant.

Indeed it is.  The fact that the C standard says that "0" is a valid
representation for a null pointer in C source code *is* relevant,
though.  That is in fact something that *wasn't* in K&R C but was
introduced in ISO Standard C, and I think it makes sense.

Anyway, this whole discussion is silly.  Can we move on to discussing
whether "disc" or "disk" is the correct spelling, or something else
equally productive? :)

Paul.
