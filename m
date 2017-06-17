From: Dave Watson <davejwatson@fb.com>
Subject: Re: [PATCH v3 net-next 3/4] tls: kernel TLS support
Date: Fri, 16 Jun 2017 17:35:20 -0700
Message-ID: <20170617003520.GA58072@davejwatson-mba.local>
References: <cover.1497465295.git.davejwatson@fb.com>
 <20170614183739.GA80368@davejwatson-mba.dhcp.thefacebook.com>
 <20170616135846.6d6011db@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        <herbert@gondor.apana.org.au>, <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        <nmav@gnutls.org>, <fridolin.pokorny@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170616135846.6d6011db@xeon-e3>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/16/17 01:58 PM, Stephen Hemminger wrote:
> On Wed, 14 Jun 2017 11:37:39 -0700
> Dave Watson <davejwatson@fb.com> wrote:
> 
> > --- /dev/null
> > +++ b/net/tls/Kconfig
> > @@ -0,0 +1,12 @@
> > +#
> > +# TLS configuration
> > +#
> > +config TLS
> > +	tristate "Transport Layer Security support"
> > +	depends on NET
> > +	default m
> > +	---help---
> > +	Enable kernel support for TLS protocol. This allows symmetric
> > +	encryption handling of the TLS protocol to be done in-kernel.
> > +
> > +	If unsure, say M.
> 
> I understand that this will be useful to lots of people and most distributions
> will enable it. But the defacto policy in kernel configuration has been that
> new features in kernel default to being disabled.

Sure, will send a patch to switch to default n.
