From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 13:31:18 +0100
Message-ID: <20050124123118.GR23931@postel.suug.ch>
References: <41F432BD.3000300@davidcoulson.net> <20050124003241.GJ23931@postel.suug.ch> <41F44FD6.4000205@davidcoulson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Coulson <david@davidcoulson.net>
Content-Disposition: inline
In-Reply-To: <41F44FD6.4000205@davidcoulson.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David Coulson <41F44FD6.4000205@davidcoulson.net> 2005-01-23 20:31
> Thomas Graf wrote:
> 
> >Protocol: 17 (UDP)
> >Checksum: 0x7b08
> >Source: 211.32.117.11 (korean ip)
> >Destination: 10.1.1.5
> >
> >[0] The originator of this packet is likely a BSD based
> >UNIX box. It is unlikely that it dropped to 49 from 128
> >which I think is the base TTL windows uses. Only guessing
> >though.
> 
> Looks like a DNS packet. AFAIK, 53 is the only UDP port I NAT through 
> from the outside to 10.1.1.5. No idea if that really matters or not, 
> with respect to the contents of the IP packet.

Yes, this explains the repetive payload. Can you provide your complete
netfilter rule set?
