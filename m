From: "David S. Miller" <davem@redhat.com>
Subject: Re: MLD compatibility mode doesn't account for extension headers
 [PATCH]
Date: Fri, 21 Nov 2003 16:46:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031121164621.277f283d.davem@redhat.com>
References: <OF7F1DDE00.E61D92DC-ON88256DE6.00004F45@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF7F1DDE00.E61D92DC-ON88256DE6.00004F45@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Nov 2003 17:08:07 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

>       The MLD v1 compatibility mode checks don't account for the
> fact that extension headers are included in the ipv6 payload_len field.
> That makes MLDv1 queries that include extension headers (like
> Router Alert) appear to be v2 packets.
>       The below patch fixes the problem.

Looks good.  I assume that all extension headers must appear
_before_ the igmp stuff, and therefore no other headers may
appear afterwards.

I'll apply this, thanks.
