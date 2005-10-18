From: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
Subject: Re: [PATCH] X25: Add ITU-T facilites
Date: Tue, 18 Oct 2005 13:37:02 -0200
Message-ID: <20051018153702.GC23167@mandriva.com>
References: <1129513666.3747.50.camel@localhost.localdomain> <20051017022826.GA23167@mandriva.com> <1129615767.3695.15.camel@localhost.localdomain> <20051018.152318.68554424.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ahendry@tusc.com.au, eis@baty.hanse.de, linux-x25@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-x25-owner@vger.kernel.org>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20051018.152318.68554424.yoshfuji@linux-ipv6.org>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Oct 18, 2005 at 03:23:18PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ escreveu:
> In article <1129615767.3695.15.camel@localhost.localdomain> (at Tue, 18 Oct 2005 16:09:27 +1000), Andrew Hendry <ahendry@tusc.com.au> says:
> 
> > +/* 
> > +*     ITU DTE facilities
> > +*     Only the called and calling address
> > +*     extension are currently implemented.
> > +*     The rest are in place to avoid the struct
> > +*     changing size if someone needs them later
> > ++ */
> > +struct x25_dte_facilities {
> > +	unsigned int    calling_len, called_len;
> > +	char            calling_ae[20];
> > +	char            called_ae[20];
> > +	unsigned char   min_throughput;
> > +	unsigned short  delay_cumul;
> > +	unsigned short  delay_target;
> > +	unsigned short  delay_max;
> > +	unsigned char   expedited;
> > +};
> 
> Why don't you use fixed size members?
> And we can eliminate 8bit hole.
> 
> struct x25_dte_facilities {
>      u32             calling_len
>      u32             called_len;

I guess the two above can be 'u8' as they refer to calling_ae and called_ae
that at most will be '20'?

>      u8              calling_ae[20];
>      u8              called_ae[20];

- Arnaldo
