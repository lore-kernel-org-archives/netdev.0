From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: 06 Jan 2005 09:03:57 -0500
Message-ID: <1105020237.2314.26.camel@jzny.localdomain>
References: <20050103125635.GB26856@postel.suug.ch>
	 <20050104223612.GN26856@postel.suug.ch>
	 <1104894728.1117.56.camel@jzny.localdomain>
	 <20050105110048.GO26856@postel.suug.ch>
	 <1104931991.1117.152.camel@jzny.localdomain>
	 <20050105144514.GQ26856@postel.suug.ch>
	 <20050105164832.GB17836@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050105164832.GB17836@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-05 at 11:48, Thomas Graf wrote:

> Here's what I mean, it moves the u32 match as-is to an ematch so it
> benefits from logic relations, inversion and can be used from other
> classifiers as well. All we have to do is set info->ptr and
> info->nexthdr to ptr respetively off2 before we evaluate the ematch
> tree. The pkt_info struct is then passed to tcf_em_tree_match and
> made available to every ematch.
> 
> Thoughts?

I think this is fine; getting into complicated-land with off2 etc but
fine and does not preclude (and is lower importance in my opinion) than
having u32 do its own magic. 
Note again Thomas: I do realize its more work to do the ematch/match
thing ;->

cheers,
jamal
