From: "David S. Miller" <davem@davemloft.net>
Subject: Re: A bug in the Kernel?
Date: Sun, 27 Feb 2005 11:33:01 -0800
Message-ID: <20050227113301.44b49e6b.davem@davemloft.net>
References: <1125.80.249.146.137.1109520029.squirrel@mx.imec.msu.ru>
	<4221F4BC.1080409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: itkes@fat.imec.msu.ru, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4221F4BC.1080409@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 27 Feb 2005 17:26:36 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Good catch, this bug was introduced when switching to
> hlist_for_each_entry().

What a dumb bug.  I'll just put a "next:" label before the "i++;"
and have the continue instead be a "goto next;".

Thanks.
