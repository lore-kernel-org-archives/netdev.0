From: bert hubert <ahu@ds9a.nl>
Subject: Re: ipsec, nat-t, iproute2?
Date: Fri, 30 Jul 2004 20:12:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730181246.GA7431@outpost.ds9a.nl>
References: <20040730170726.GA5144@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040730170726.GA5144@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 30, 2004 at 07:07:26PM +0200, bert hubert wrote:

> 2) I hear people are working on iproute so it can use XFRM_USER, is this
> code available somewhere?

Ok, this is rather embarassing, turns out that this is all discussed on my
own LARTC mailinglist. I should read it every once in a while. The code is
in the bitkeeper described on http://developer.osdl.org/dev/iproute2/

> 3) NAT-Traversal, how does one set this up either using setkey,
> iproute2+stuff, or XFRM_USER? Is it supposed to work right now?
> Is NAT-T 'UDP_ENCAP_ESPINUDP'?

Sadly, this code does not yet do encap. *Swan appears to have support for
this over XFRM_USER, currently reading it.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
