From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH} ARP auto-sizing for 2.4.24 - 2.4.26-pre3
Date: Mon, 15 Mar 2004 13:57:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315135753.28b945fa.davem@redhat.com>
References: <20040315134412.314b5e23.davem@redhat.com>
	<Pine.LNX.4.44.0403152350260.6903-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: timg@tpi.com, anton@samba.org, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0403152350260.6903-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Mar 2004 23:55:04 +0200 (EET)
Pekka Savola <pekkas@netcore.fi> wrote:

> Isn't there a problem when an outside attacker brute-force pings every 
> IP address in some order?  The intent here is to overload the router 
> to do a lot of ARP/ND requests which result to nothing.

Since another request for the same IP won't spam out another ARP
request whilst we have an existing entry in state "resolve in progress",
the damage is quite limited I'd say.

Sounds to me like the backlog of packets we keep around for each
"resolve in progress" neighbour cache entry is more interesting
for DoS purposes :-)
