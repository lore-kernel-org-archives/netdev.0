From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: Action repeat
Date: Wed, 4 May 2005 14:31:57 +0200
Message-ID: <20050504123157.GA18452@postel.suug.ch>
References: <4273CAB7.6080403@trash.net> <1114890709.8929.147.camel@localhost.localdomain> <20050430200848.GF577@postel.suug.ch> <1114894202.8929.165.camel@localhost.localdomain> <20050430215550.GH577@postel.suug.ch> <1114900485.8929.171.camel@localhost.localdomain> <20050430235809.GI577@postel.suug.ch> <1115035838.8929.236.camel@localhost.localdomain> <20050502150632.GM577@postel.suug.ch> <1115207194.7665.109.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115207194.7665.109.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1115207194.7665.109.camel@localhost.localdomain> 2005-05-04 07:46
> Basically, something along those lines (eg struct tca_pkt_info) in which
> the tcf_result is one of the components should do it. 
> 
> I would be satisfied with this being the structure in the ->act()
> parameters because then it could also be used to pass action-metadata
> around (no action written so far needs such coordination, but its been
> one of those things i have been thinking of for some dynamic creations
> for example  where the return code is insufficient to describe things).
> Patrick, either you or i could do it. It doesnt matter if at the moment
> the structure only contains tcf_result or elements of tcf_result because
> i will add more to it later. Then we could kill access to tc_classid in
> exec()

Sounds good.

> Global I believe means you dont reset it when you clone/copy.
> skb->tc_verd is only cleared when we free the skb at the moment and
> transfered when we clone or copy. A bit or two could be reserved in the
> tc_verd to say "clear tc_classid" and have the meta action decide if it
> is global(dont clear) or not(clear - current behavior) during
> clone/copy . Does this sound reasonable?

I have no objections but fail to see why we want to clear it anyway?
