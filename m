From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next PATCH v3 3/3] net: TCP thin dupack
Date: Fri, 12 Feb 2010 13:43:09 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1002121342150.18408@melkinpaasi.cs.helsinki.fi>
References: <4B73F31F.9000204@simula.no> <4B753943.2080800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andreas Petlund <apetlund@simula.no>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>, damian@tvk.rwth-aachen.de
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B753943.2080800@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Feb 2010, William Allen Simpson wrote:

> Andreas Petlund wrote:
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index 28e0296..c5a73ab 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -89,6 +89,8 @@ int sysctl_tcp_frto __read_mostly = 2;
> >  int sysctl_tcp_frto_response __read_mostly;
> >  int sysctl_tcp_nometrics_save __read_mostly;
> >  +int sysctl_tcp_force_thin_dupack __read_mostly;
> > +
> >  int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
> 
> Where is the sysctl initialized?

...That's offloaded to the compiler, like is done with some of the above 
ones too. There's nothing to worry in that.

-- 
 i.
