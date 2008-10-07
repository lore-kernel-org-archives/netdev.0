From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] Don't lookup the socket if there's a socket
 attached to the skb
Date: Tue, 07 Oct 2008 12:41:49 -0700 (PDT)
Message-ID: <20081007.124149.190642665.davem@davemloft.net>
References: <20081003134747.GH17843@ghostprotocols.net>
	<1223366369.35518.13.camel@nessa.odu>
	<20081007123626.GB29610@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidden@sch.bme.hu, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: acme@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081007123626.GB29610@ghostprotocols.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 7 Oct 2008 09:36:26 -0300

> Em Tue, Oct 07, 2008 at 09:59:29AM +0200, KOVACS Krisztian escreveu:
> > Don't lookup the socket if there's a socket attached to the skb
> > 
> > Use the socket cached in the skb if it's present.
> > 
> > Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
 ...
> After you fix this up, please add:
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

I made the requested fixups for him and applied the result
to net-next-2.6, thanks!
