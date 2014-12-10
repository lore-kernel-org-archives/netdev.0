From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] irda: Convert function pointer arrays and uses to const
Date: Wed, 10 Dec 2014 11:38:03 -0800
Message-ID: <1418240283.18092.15.camel@perches.com>
References: <1418236138.18092.13.camel@perches.com>
	 <3333024A-D21C-41E2-80ED-7590CE6E9BD1@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3333024A-D21C-41E2-80ED-7590CE6E9BD1@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-12-10 at 19:32 +0000, Rustad, Mark D wrote:
> On Dec 10, 2014, at 10:28 AM, Joe Perches <joe@perches.com> wrote:
[]
> > diff --git a/include/net/irda/parameters.h b/include/net/irda/parameters.h
[]
> > typedef struct {
> > -	pi_minor_info_t *pi_minor_call_table;
> > +	const pi_minor_info_t *pi_minor_call_table;
> 
> Might you want to go a little further and make it:
> 	const pi_minor_into_t * const pi_minor_call_table;
> so that the pointer itself is also constant? That could apply to some others below as well.
> 
> > 	int len;
> > } pi_major_info_t;

I don't think that's necessary as all the pi_major_info_t uses
become const and this is a typedef, but if you want to, go ahead.
