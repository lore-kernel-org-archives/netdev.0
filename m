From: bert hubert <ahu@ds9a.nl>
Subject: Re: ipsec without interface
Date: Tue, 1 Jul 2003 14:58:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701125808.GA19408@outpost.ds9a.nl>
References: <1054235787.605.21.camel@simulacron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Jellinghaus <aj@dungeon.inka.de>
Content-Disposition: inline
In-Reply-To: <1054235787.605.21.camel@simulacron>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 29, 2003 at 09:16:27PM +0200, Andreas Jellinghaus wrote:
> sure, the simple configurations work fine with kernel 2.5.* ipsec.
> But I miss the interface and things I did with it. How are these
> setups supposed to work without an interface?
> 
> a) in iptables allow everything coming from ipsec0,
>    allow only ssh and ipsec on eth0.

iptables can filter on ESP/AH presence.

> b) source address selection. put the default route on ipsec0,

Do you need a separate source address?

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
