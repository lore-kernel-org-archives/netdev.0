From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 09:18:37 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306100916330.26498@ns.istop.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092200150.28167@ns.istop.com> <20030610043453.GC23009@netnation.com>
 <20030610072444.Q37105@shell.cyberus.ca>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Kirby <sim@netnation.com>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030610072444.Q37105@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, Jamal Hadi wrote:

> As a side note, note that stateless forwarding like BSD patricie tries
> is no longer sufficient. Its no longer just looking up a nexthop, dec ttl,
> recompute csum that we are optimizing for.

It would certainly be sufficient for core routing.  If I can have flow
manipulation at no extra cost, I'll take it.  If it's going to double the
horsepower requirements, I don't want it.

-Ralph

