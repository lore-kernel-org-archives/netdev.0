From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [IPSEC] fix ref counting in __xfrm4_bundle_create()
Date: Tue, 1 Jun 2004 13:17:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040601201724.GA17412@gate.ebshome.net>
References: <20040529001450.GA647@gate.ebshome.net> <E1BTuV7-0002m2-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1BTuV7-0002m2-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, May 29, 2004 at 01:27:13PM +1000, Herbert Xu wrote:
> However, can you see if the following patch fixes this problem as well?
> It moves the dst->xfrm assignment to a spot where errors cannot occur.

Yes, your version is OK. We haven't got the crash during our testing.

Thanks a lot, Herbert.

Eugene
