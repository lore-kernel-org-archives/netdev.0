From: "Leisner, Martin" <Martin.Leisner@xerox.com>
Subject: WOL with flex filters, reflecting it in /sys
Date: Thu, 1 Oct 2009 13:55:03 -0700
Message-ID: <76FA3B279DD9DA48896E2B404944957203C09587@USA7061MS02.na.xerox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: martyleisner@yahoo.com
To: <linux-pm@lists.linux-foundation.org>, <netdev@vger.kernel.org>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

I'm looking to extend the work of Mitch Williams to support flexible
filters.
(http://www.mail-archive.com/netdev@vger.kernel.org/msg60332.html}

Looking at the problem, would it be a good idea to reflect WOL
characteristics in the /sys filesystem (instead of requiring ethtool to
set them)?

Seems straightforward and easy enough.

I know the VIA Rhinefet and Intel e1000 support filters -- and some
freescale
seems to have some front end that support filters...and we've also
implemented filters in software...

What I'm thinking of is a hierarchy in /sys/classes/net/<device>/wol/

wol/
   /flex-filters
      /0
           data -- hex data to match
           mask -- string of 1 and 0 -- if 1, the data is valid in the
bit 
                   position
      ...
      /n
	   data
         mask
  /wake_up_packet
  /traditional --r/w (0/1)
     /magic_packet
     /arp
     /unicast
     /multicast
     /broadcast
     /phy
    
marty
