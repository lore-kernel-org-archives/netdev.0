From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ppp: use {get,put}_unaligned_be{16,32}
Date: Fri, 07 Jan 2011 20:37:10 -0800 (PST)
Message-ID: <20110107.203710.71119403.davem@davemloft.net>
References: <AANLkTim=1GCah0qp8HJK31LWXPb5vAZYp+d2BTQM+Q+B@mail.gmail.com>
	<20110107.171534.193718114.davem@davemloft.net>
	<20110108031320.GA28926@brick.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, harvey.harrison@gmail.com,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: paulus@samba.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20110108031320.GA28926@brick.ozlabs.ibm.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Mackerras <paulus@samba.org>
Date: Sat, 8 Jan 2011 14:13:20 +1100

> On Fri, Jan 07, 2011 at 05:15:34PM -0800, David Miller wrote:
> 
>> I have to say that every time I go read the header parsing code in the
>> PPP driver, I absolutely regret it.
>> 
>> And Changli's patch fixes some of the readability problems.
> 
> It's up to you whether you merge the patch or not, but surely you
> agree it needs more than a zero-line description?

It's entire sufficient to me.

He de-open-coded {get,put}_unaligned_be{16,32}() and when open-coding
is eliminated in this way a commit message of "Use {helper function
foo}." is more than enough.
