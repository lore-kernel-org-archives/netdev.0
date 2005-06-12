From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 20:47:07 +0300
Message-ID: <200506122047.07257.vda@ilport.com.ua>
References: <42A9C607.4030209@unixtrix.com> <200506122010.33075.vda@ilport.com.ua> <20050612173614.GA11157@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, xschmi00@stud.feec.vutbr.cz,
        alastair@unixtrix.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: <20050612173614.GA11157@alpha.home.local>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 12 June 2005 20:36, Willy Tarreau wrote:
> On Sun, Jun 12, 2005 at 08:10:33PM +0300, Denis Vlasenko wrote:
> > > Does it seem appropriate for mainline ? In this case, I would also backport
> > > it to 2.4 and send it to you for inclusion.
> > 
> > It does not contain a comment why it is configurable.
> 
> You're right. Better with this ?

Very nice. BTW, is there any real world applications which
ever used this?

> +	If you want backwards compatibility with every possible application,
> +	you should set it to 1. If you prefer to enhance security on your
> +	systems at the risk of breaking very rare specific applications, you'd
> +	better let it to 0.
> +	Default: 0

This text leaves an impression that they exist.
--
vda
