From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: action stats double dip
Date: 25 Mar 2005 18:06:31 -0500
Message-ID: <1111791991.1091.732.camel@jzny.localdomain>
References: <1111767913.1091.530.camel@jzny.localdomain>
	 <1111768884.1092.533.camel@jzny.localdomain>
	 <20050325200650.GC3086@postel.suug.ch>
	 <1111782325.1089.641.camel@jzny.localdomain>
	 <20050325204110.GF3086@postel.suug.ch>
	 <1111786752.1090.678.camel@jzny.localdomain>
	 <20050325215841.GH3086@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050325215841.GH3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 16:58, Thomas Graf wrote:
> * jamal <1111786752.1090.678.camel@jzny.localdomain> 2005-03-25 16:39

> 
> Agreed, I have to look into this more deeply. As it seems things
> are really messed up anyways. We have the same stats TLV being
> put into TCA_OPTIONS but also into the root array which I think
> lead you to move that TCA_ACT_STATS, both is wrong ;->
> 

The stats for actions seem fine - Andy and to a small extent myself have
verified this. 
What i moved was TCA_ACT_STATS which really belongs to the action
hierachy. The other level still has STATS like before used by qdiscs
etc. I quickly checked those and they looked sane as well. Trust me i
panicked after looking at the code the first time i found the stats were
messed when Andy reported them. Then i realized it was a simple issue of
moving around TCA_ACT_STATS.

cheers,
jamal
