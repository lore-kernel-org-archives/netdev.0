From: jamal <hadi@cyberus.ca>
Subject: Re: patch: Action repeat
Date: Sat, 30 Apr 2005 18:34:45 -0400
Message-ID: <1114900485.8929.171.camel@localhost.localdomain>
References: <1114879817.8929.117.camel@localhost.localdomain>
	 <4273BB30.1050402@trash.net> <4273BBAA.6060405@trash.net>
	 <1114882045.8929.123.camel@localhost.localdomain>
	 <4273CAB7.6080403@trash.net>
	 <1114890709.8929.147.camel@localhost.localdomain>
	 <20050430200848.GF577@postel.suug.ch>
	 <1114894202.8929.165.camel@localhost.localdomain>
	 <20050430215550.GH577@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050430215550.GH577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-30-04 at 23:55 +0200, Thomas Graf wrote:
> 
> Right, although I would define local as per device on either ingress
> or egress. What I'm looking for in particular is a way to transfer
> classification decisions from one device to another. A common case
> for this is if a packet enters the packet, gets encapsulated and
> leaves the host in some kind of tunnel. It's pretty hard to do
> classification on the tunnel device so you want to do it before
> the encapsulation and copy the result over to the tunnel. We can
> use nfmark for this but i'd rather have a well defined variable
> for this.

Perhaps we can reuse classid by flagging somewhere? 
A good place to do it is tc_verdict. There a few bits still left.
We could set a bit to say the meaning of classid to be global vs local.

cheers,
jamal
