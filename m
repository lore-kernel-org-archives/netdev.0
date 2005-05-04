From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: Action repeat
Date: Wed, 4 May 2005 15:48:15 +0200
Message-ID: <20050504134815.GD18452@postel.suug.ch>
References: <20050430215550.GH577@postel.suug.ch> <1114900485.8929.171.camel@localhost.localdomain> <20050430235809.GI577@postel.suug.ch> <1115035838.8929.236.camel@localhost.localdomain> <20050502150632.GM577@postel.suug.ch> <1115207194.7665.109.camel@localhost.localdomain> <20050504123157.GA18452@postel.suug.ch> <1115211549.7665.140.camel@localhost.localdomain> <20050504132822.GB18452@postel.suug.ch> <1115213600.7665.166.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115213600.7665.166.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1115213600.7665.166.camel@localhost.localdomain> 2005-05-04 09:33
> On Wed, 2005-04-05 at 15:28 +0200, Thomas Graf wrote:
> > * jamal <1115211549.7665.140.camel@localhost.localdomain> 2005-05-04 08:59
> > > If its scope is local i.e for one device, then not reseting could
> > > confuse the next device that sees it and tries to classify on it.
> > 
> > OK, so we're not talking about a reset in action_exec() but rather
> > in tc_classify() or enqueue()?
> 
> in skb_clone() and friends.
> Look at CONFIG_NET_CLS_ACT in net/core/skbuff.c

Yes this solves the case for dummy devices etc but how would
this cause a reset on the way from ingress to egress?
