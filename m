From: Miika Komu <miika@iki.fi>
Subject: Re: IPsec performance
Date: Tue, 3 May 2005 08:25:15 +0300 (EEST)
Message-ID: <Pine.GSO.4.58.0505030820160.24686@kekkonen.cs.hut.fi>
References: <Pine.GSO.4.58.0505022117190.25766@kekkonen.cs.hut.fi>
 <Pine.GSO.4.58.0505022204090.25766@kekkonen.cs.hut.fi>
 <Pine.LNX.4.62.0505030248020.26815@kaber.coreworks.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <Pine.LNX.4.62.0505030248020.26815@kaber.coreworks.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 May 2005, Patrick McHardy wrote:

> On Mon, 2 May 2005, Miika Komu wrote:
> >> I compared TCP-over-NULL-ESP vs. plain-TCP throughput with "ttcp" tool and
> >> obtained the following results:
> >>
> >> Plain-TCP:	11 megabytes/s
> >> NULL-ESP:	2.5 megabytes/s
> >>
> > I browsed the archives also and found this one:
> >
> > http://oss.sgi.com/archives/netdev/2004-12/msg00801.html
>
> null encryption uses a block size of 1, which causes inefficent handling
> of the data. I'm unsure if some hack for this specific case is worth it
> since its only meant for testing.

Thanks for your response.

However, this does explain why I got only 1.9 megabytes/s with 3DES.

-- 
Miika Komu              miika@iki.fi          http://www.iki.fi/miika/
