From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Thu, 11 Jul 2002 18:00:10 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <15661.43914.786721.347779@robur.slu.se>
References: <20020710223237.GA7995@orr.falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se, greearb@candelatech.com,
   garzik@mandrakesoft.com
Return-path: <owner-netdev@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <20020710223237.GA7995@orr.falooley.org>
List-Id: netdev.vger.kernel.org


Jason Lunz writes:
 > 
 > I've backported the most recent napi sources I could find to 2.4.19-rc1.
 > The patches are available at http://orr.falooley.org/pub/linux/net/.

 Thanks!
 Yes but remember it's experimental branch and hopefully soon we can kill 
 most of it... 

 > Does anyone know of more recent NAPI conversions? Robert Olsson tells me
 > Jeff Garzik has a more recent tulip conversion, but there are _no_ napi
 > net drivers in 2.5.25 and I haven't found any others except for those
 > mentioned at the NAPI ftp site.

 Current tulip seems fine but it is complex. Eventually it will be  better 
 if uses a simliar scheme as e1000 and tg3. Leaving all "interrupt work" to 
 dev->poll. And yes it was forked off linux-2.4.2 so Jeffs later work is
 not included.

 
 The e1000 4.2.4 is well tested. But for 4.2.17 I more or less moved the path 
 onto it.

 I've put a reference to your work in README

 Cheers.

						--ro
