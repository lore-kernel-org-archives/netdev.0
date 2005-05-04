From: jamal <hadi@cyberus.ca>
Subject: Re: patch: Action repeat
Date: Wed, 04 May 2005 09:33:20 -0400
Message-ID: <1115213600.7665.166.camel@localhost.localdomain>
References: <20050430200848.GF577@postel.suug.ch>
	 <1114894202.8929.165.camel@localhost.localdomain>
	 <20050430215550.GH577@postel.suug.ch>
	 <1114900485.8929.171.camel@localhost.localdomain>
	 <20050430235809.GI577@postel.suug.ch>
	 <1115035838.8929.236.camel@localhost.localdomain>
	 <20050502150632.GM577@postel.suug.ch>
	 <1115207194.7665.109.camel@localhost.localdomain>
	 <20050504123157.GA18452@postel.suug.ch>
	 <1115211549.7665.140.camel@localhost.localdomain>
	 <20050504132822.GB18452@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050504132822.GB18452@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-04-05 at 15:28 +0200, Thomas Graf wrote:
> * jamal <1115211549.7665.140.camel@localhost.localdomain> 2005-05-04 08:59
> > On Wed, 2005-04-05 at 14:31 +0200, Thomas Graf wrote:
> > > * jamal <1115207194.7665.109.camel@localhost.localdomain> 2005-05-04 07:46
> > 
> > > > tc_verd to say "clear tc_classid" and have the meta action decide if it
> > > > is global(dont clear) or not(clear - current behavior) during
> > > > clone/copy . Does this sound reasonable?
> > > 
> > > I have no objections but fail to see why we want to clear it anyway?
> > > 
> > 
> > If its scope is local i.e for one device, then not reseting could
> > confuse the next device that sees it and tries to classify on it.
> 
> OK, so we're not talking about a reset in action_exec() but rather
> in tc_classify() or enqueue()?

in skb_clone() and friends.
Look at CONFIG_NET_CLS_ACT in net/core/skbuff.c

cheers,
jamal
