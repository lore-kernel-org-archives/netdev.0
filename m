From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] /proc/net/stat/rt_cache has a wrong header
Date: Fri, 18 Mar 2005 08:50:56 -0800
Message-ID: <20050318085056.0869394b@dxpl.pdx.osdl.net>
References: <4238C388.5040303@cosmosbay.com>
	<423AC418.6080903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <423AC418.6080903@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 13:05:44 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Hello
> 
> The header of /proc/net/stat/rt_cache misses the 'in_slow_mc' field.
> This patch adds it.

Current iproute2 tools adapt to additional fields, but wouldn't this be breaking
the API for other tools? (if any)
