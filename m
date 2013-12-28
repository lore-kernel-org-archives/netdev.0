From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: xtables make functions local
Date: Sat, 28 Dec 2013 13:50:43 +0100
Message-ID: <20131228125043.GA24243@localhost>
References: <20131227120937.702bc383@nehalam.linuxnetplumber.net>
 <20131228.012129.170537567898112631.davem@davemloft.net>
 <alpine.LSU.2.11.1312281230300.16819@nerf08.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, David Miller <davem@davemloft.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1312281230300.16819@nerf08.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 28, 2013 at 12:31:26PM +0100, Jan Engelhardt wrote:
> On Saturday 2013-12-28 07:21, David Miller wrote:
> 
> >From: Stephen Hemminger <stephen@networkplumber.org>
> >Date: Fri, 27 Dec 2013 12:09:37 -0800
> >
> >> A couple of functions only used in x_tables, don't need to be global
> >> 
> >> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> >
> >I'll let Pablo pick this up, thanks.
> 
> Negative, there is at least one known external modules using these.

Unfortunately, we cannot keep symbols for out of tree modules, that
has been the longterm policy.
