From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: action stats double dip
Date: Fri, 25 Mar 2005 22:58:41 +0100
Message-ID: <20050325215841.GH3086@postel.suug.ch>
References: <1111767913.1091.530.camel@jzny.localdomain> <1111768884.1092.533.camel@jzny.localdomain> <20050325200650.GC3086@postel.suug.ch> <1111782325.1089.641.camel@jzny.localdomain> <20050325204110.GF3086@postel.suug.ch> <1111786752.1090.678.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111786752.1090.678.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1111786752.1090.678.camel@jzny.localdomain> 2005-03-25 16:39
> Well, old tc binaries exist and should continue to work. I suppose
> we can put a time limit on how long such things can be supported.
> It could get killed if it becomes a nuisance but it will have to be
> advertised in some kernel changelogs 

Yes but they should continue to work via the compatiblity code
in the action, right? It's just that we could get rid of all
the ifdef mess. These bugs don't come out of nowhere, the main
cause is exactly this mess I think ;->

> >  Don't waste any time on this, it's my fault so let me
> > resolve this.
> 
> I dont think that its devasting actually after i moved around 
> the TCA_ACT_STAT attribute in previous patch (so even without that
> fix all that would happen is tb[TCA_ACT_STATS] will be written twice.
> And i dont think its your fault - bugs are expected(note my wisecrack
> comments to Andy Furniss;->) and the patch was widely discussed none of
> us saw this. 
> Dave has already taken in the patch - if you want to amend things
> i would suggest you do it against the patch i posted.

Agreed, I have to look into this more deeply. As it seems things
are really messed up anyways. We have the same stats TLV being
put into TCA_OPTIONS but also into the root array which I think
lead you to move that TCA_ACT_STATS, both is wrong ;->
