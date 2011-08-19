From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 68/75] hv: netvsc: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:46:27 +0100
Message-ID: <1313761587.5010.365.camel@zakaz.uk.xensource.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
	<1313760467-8598-68-git-send-email-ian.campbell@citrix.com>
	<20110819133739.GA3715@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	Abhishek Kane <v-abkane@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Haiyang Zhang <haiyangz@microsoft.com>, Greg
	Kroah-Hartman <gregkh@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20110819133739.GA3715@shale.localdomain>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-08-19 at 14:37 +0100, Dan Carpenter wrote:
> On Fri, Aug 19, 2011 at 02:27:40PM +0100, Ian Campbell wrote:
> >  	/* usually there's just one frag */
> > -	skb_frag_set_page(skb, 0, gl->frags[0].page);
> > +	skb_frag_set_page(skb, 0, gl->frags[0].page.p);	/* XXX */
> 
> There are bunch of new /* XXX */ comments.  What are they for?

They are a reminder referring to the dilemma I mentioned in the intro
mail. Basically that ".p" is ugly because gl->frags[0].page isn't
actually a paged fragment, it's just that this driver uses skb_frag_t in
its internal datastructures.

Ian.
