From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Tue, 9 Nov 2004 18:04:11 -0500
Message-ID: <20041109230411.GA91891@calma.pair.com>
References: <20041109205358.GA64015@calma.pair.com> <E1CRdBr-0001P2-00@gondolin.me.apana.org.au> <20041109224337.GB87321@calma.pair.com> <20041109225812.GA6001@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20041109225812.GA6001@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In 2.4 it is entirely possible to have a record broken up into two
> reads.  There is no guarantee that the two reads will be reading the
> same record.

Let me make sure I understand what you're saying here...

You're saying that since pidentd is calling fgets(), that can actually result
in multiple read() calls.  Because of this, the first half of the line
containing the address:port pairs can be with respect to one socket, and the 
second half containing the euid can be from another socket?

Chad
