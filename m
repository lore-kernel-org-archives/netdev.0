From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: New NAPI work applied...
Date: Thu, 5 Feb 2004 23:31:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16418.50222.708197.388268@robur.slu.se>
References: <4022A2F5.7050107@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4022A2F5.7050107@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeff Garzik writes:
 > 
 > FYI to all (particularly Robert O and Hirofumi-san),
 > 
 > 8139too and tulip NAPI support is now in upstream 2.6.x tree.
 > 
 
Thanks Jeff!

The original tulip patch was done by Alexey and came w. the NAPI kernel patch.
And the interrupt mitigation part was stolen and simplified from Jamal. :-)


BTW. I'm hacking with a userland app to get interface stats. It's fork of a
Alexey program too. ifstat. In my take it's ifstat2 and looks like:

 
ifstat2 eth*
             RX --------------------------   TX -------------------------
eth0          704.9 M bit/s       59 k pps      3.2 M bit/s        5 k pps 
eth1             16   bit/s        0   pps    215.8 k bit/s      431   pps 
eth2          220.8 k bit/s      441   pps        0   bit/s        0   pps 
eth3              0   bit/s        0   pps    219.5 k bit/s      438   pps

It's fits between ip -s link and ethtool -S 

ftp://robur.slu.se/pub/Linux/net-development/ifstat2/

A diet linked version for ix86:
http://robur.slu.se/diet/bin-i386/ifstat2


Cheers.
						--ro
