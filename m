From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Thu, 19 May 2005 01:31:13 +0200
Message-ID: <20050518233113.GG15391@postel.suug.ch>
References: <E1DYWNS-0004ju-00@gondolin.me.apana.org.au> <OFD80D42F2.31DFC921-ON88257005.007ABBCD-88257005.007B23EA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com, rick.jones2@hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFD80D42F2.31DFC921-ON88257005.007ABBCD-88257005.007B23EA@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David Stevens <OFD80D42F2.31DFC921-ON88257005.007ABBCD-88257005.007B23EA@us.ibm.com> 2005-05-18 15:24
>         If you're going to add an IP option, you can eliminate the
> problem entirely. Just add an "extended IP ID" IP option and give
> it as many bits as you want-- make that the high order of an n+16-bit
> IP ID.

I was thinking of something more nasty such as using as value
for this flag (IP_DF|IP_MF) ;->
