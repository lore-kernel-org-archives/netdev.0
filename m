From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tulip: Remove private "strncmp"
Date: Tue, 09 Dec 2014 13:45:47 -0500 (EST)
Message-ID: <20141209.134547.1067254735927828157.davem@davemloft.net>
References: <1417689040-14958-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417689040-14958-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Thu,  4 Dec 2014 11:30:40 +0100

> The comment says that the built-in strncmp didn't work. That is not
> surprising, as apparently "str" semantics are not really what is
> wanted (hint: de4x5_strncmp only stops when two different bytes are
> encountered or the end is reached; not if either byte happens to be
> 0). de4x5_strncmp is actually a memcmp (except for the signature and
> that bytes are not necessarily treated as unsigned char); since only
> the boolean value of the result is used we can just replace
> de4x5_strncmp with memcmp.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied, thanks.
