From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 17:58:13 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.175813.74726237.davem@redhat.com>
References: <Pine.LNX.4.51.0306101956520.7801@ns.istop.com>
	<20030610.165759.78731321.davem@redhat.com>
	<Pine.LNX.4.51.0306102030530.12166@ns.istop.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, hadi@shell.cyberus.ca, xerox@foonet.net,
   sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com, ralph@istop.com
In-Reply-To: <Pine.LNX.4.51.0306102030530.12166@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ralph Doncaster <ralph@istop.com>
   Date: Tue, 10 Jun 2003 20:41:13 -0400 (EDT)

   On Tue, 10 Jun 2003, David S. Miller wrote:
   
   > Guess you never run tcpdump nor use packet schedulers.
   
   So because some (in the case of a core router almost none) of the packets
   will need a timestamp, you do it for every single one of them?

In order to be accurate, we must obtain the timestamp
exactly when we receive the packet.

But until we know that the packet is for us or not (which
requires a route lookup), we don't know if we actually need
the timestamp or not.

This is not some arbitrary thing, this is how you have to
implement this.  It's not like we said "screw everyone,
let's get a timestamp all the time whether we need it or
not." :-)
