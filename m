From: David Coulson <david@davidcoulson.net>
Subject: Re: skb_checksum_help
Date: Sun, 23 Jan 2005 20:31:02 -0500
Message-ID: <41F44FD6.4000205@davidcoulson.net>
References: <41F432BD.3000300@davidcoulson.net> <20050124003241.GJ23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050124003241.GJ23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Thomas Graf wrote:

> Protocol: 17 (UDP)
> Checksum: 0x7b08
> Source: 211.32.117.11 (korean ip)
> Destination: 10.1.1.5
> 
> [0] The originator of this packet is likely a BSD based
> UNIX box. It is unlikely that it dropped to 49 from 128
> which I think is the base TTL windows uses. Only guessing
> though.

Looks like a DNS packet. AFAIK, 53 is the only UDP port I NAT through 
from the outside to 10.1.1.5. No idea if that really matters or not, 
with respect to the contents of the IP packet.

David

-- 
David J. Coulson
email: david@davidcoulson.net
web: http://www.davidcoulson.net/
phone: (216) 920-3100 / (216) 258-4942
