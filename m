From: d_vangreg <d.vangreg@inwind.it>
Subject: kern-25-net-core-bug
Date: Wed, 1 May 2002 19:22:07 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <200205011800.g41I0WwJ029694@oss.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

--> jgarzik@mandrakesoft.com
--> pavel@atrey.karlin.mff.cuni.cz
--> netdev@oss.sgi.com

kernel-2.5.11  &  kernel-2.4.12 Bug-REPORT(net-core-dev)

Action: kernel-compilation from sources.

"make bzImage" stopped in error at:
net/core/dev.c: 1465 .. using return value of function declared void ...

I guessed (as errata):     ret=handle_diverter(skb);

& tried  (as corrige):     handle_diverter(skb);

it worked: bzImage did compile, but I'm not sure this was the correct 
solution.

System=Linux-Slakware-8.0 arch=i386 (CPU=athlon)
compile-tools: gcc-3.0.4,  glibc-2.2.5
GUI: KDE-3.0b2

END REPORT

Sender: <d.vangreg@inwind.it>
