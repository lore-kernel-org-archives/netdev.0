From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: Last night Linus bk - netfilter busted?
Date: Sun, 13 Mar 2005 01:54:02 -0500
Message-ID: <200503130154.03777.dtor_core@ameritech.net>
References: <E1D9rZX-0004KE-00@gondolin.me.apana.org.au> <423221FF.8020103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        netfilter-devel@lists.netfilter.org
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <423221FF.8020103@trash.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 11 March 2005 17:55, Patrick McHardy wrote:
> Herbert Xu wrote:
> > Patrick McHardy <kaber@trash.net> wrote:
> > 
> >>You're right, good catch. IPT_RETURN is interpreted internally by
> >>ip_tables, but since the value changed it isn't recognized by ip_tables
> >>anymore and returned to nf_iterate() as NF_REPEAT. This patch restores
> >>the old value.
> > 
> > 
> > Please fix netfilter_arp while you're at it since it does exactly
> > the same thing.
> 
> New patch attached, thanks.
> 

If this is of any interest, yesterday's pull from Linux plus this patch
seem to be working fine here.

Thank you.

-- 
Dmitry
