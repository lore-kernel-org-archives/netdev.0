From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Mon, 9 Feb 2004 08:08:30 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402090806040.11837-100000@netcore.fi>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 8 Feb 2004, Julian Anastasov wrote:
> 	Appended is a patch that modifies proxy_arp to check
> the target's neighbour state before reporting any information
> to requestors. The benefit is that the availability of the target
> host is properly reported to the requestor, we prefer not to send
> replies when target is unreachable. 

As this seems to make the proxy_arp more intelligent, maybe you should 
take a look at:

http://www.ietf.org/internet-drafts/draft-thaler-ipv6-ndproxy-01.txt

(which, at the moment, specifies proxy arp/ND for both IPv4 and IPv6)

and see how close our implementation is wrt. to that spec, whether the 
above spec is better or worse, or whether there may be room for 
improvement otherwise as well?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
