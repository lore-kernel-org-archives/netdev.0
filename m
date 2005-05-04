From: jamal <hadi@cyberus.ca>
Subject: Re: patch: Action repeat
Date: Wed, 04 May 2005 09:53:02 -0400
Message-ID: <1115214782.7665.184.camel@localhost.localdomain>
References: <20050430215550.GH577@postel.suug.ch>
	 <1114900485.8929.171.camel@localhost.localdomain>
	 <20050430235809.GI577@postel.suug.ch>
	 <1115035838.8929.236.camel@localhost.localdomain>
	 <20050502150632.GM577@postel.suug.ch>
	 <1115207194.7665.109.camel@localhost.localdomain>
	 <20050504123157.GA18452@postel.suug.ch>
	 <1115211549.7665.140.camel@localhost.localdomain>
	 <20050504132822.GB18452@postel.suug.ch>
	 <1115213600.7665.166.camel@localhost.localdomain>
	 <20050504134815.GD18452@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050504134815.GD18452@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-04-05 at 15:48 +0200, Thomas Graf wrote:
> * jamal <1115213600.7665.166.camel@localhost.localdomain> 2005-05-04 09:33

> > in skb_clone() and friends.
> > Look at CONFIG_NET_CLS_ACT in net/core/skbuff.c
> 
> Yes this solves the case for dummy devices etc but how would
> this cause a reset on the way from ingress to egress?

If the verdict is not to reset, there should be no clearing of those
fields from ingress -> egress until the skb is either freed or someone
else along the path resets it. Cloning or copying inherits. Am i missing
something?

cheers,
jamal 
