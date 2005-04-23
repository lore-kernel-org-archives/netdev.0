From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Problem with IPSEC tunnel mode
Date: Sat, 23 Apr 2005 10:52:31 -0700
Message-ID: <20050423105231.082041f3.davem@davemloft.net>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au>
	<200504221342.10675.wolfgang.walter@studentenwerk.mhn.de>
	<1114172084.7679.15.camel@localhost.localdomain>
	<200504221522.49403.wolfgang.walter@studentenwerk.mhn.de>
	<1114278545.7669.75.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wolfgang.walter@studentenwerk.mhn.de, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1114278545.7669.75.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 23 Apr 2005 13:49:04 -0400
jamal <hadi@cyberus.ca> wrote:

> Do you know why pfkey doesnt scale? Herbert?

It does no queueing, pfkey responses are generated
in one huge atomic send back to the application's socket.

It's just like BSD routing sockets, very poorly designed.
