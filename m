From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] string matching ematch
Date: Wed, 26 Jan 2005 13:03:23 -0800
Message-ID: <20050126130323.2dc10187.davem@davemloft.net>
References: <20050126150714.GL31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050126150714.GL31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 26 Jan 2005 16:07:14 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> I'd like to discuss the string matching ematch, I don't care about the
> algorithm used but rather whether to make it stateful, match over
> fragments, etc.

I think you'll need to make it stateful.

I assume this is meant to be used for things like catching references
to "Falun Gong" in SMTP sessions and stuff like that.  Not that I know
any entity interested in such applications :-)

Anyways, if the string goes across the TCP data portion of multiple
packets, statefulness becomes necessary to catch it.  Right?
