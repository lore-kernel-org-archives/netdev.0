From: Mark Hahn <hahn@physics.mcmaster.ca>
Subject: per-route TCP windows?
Date: Thu, 14 Jul 2005 21:09:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.44.0507142101310.16602-100000@coffee.psychology.mcmaster.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I was recently fiddling with TCP performance on long-fat links,
and noticed that iproute2 seems to allow one to set a per-route window.

is this implemented in the stack?  I gave it one try and it didn't
seem to work, but I admit I haven't delved into the code yet.

we'd like to tune for some 10Gb, 3-6 ms links, mainly to move large files
between our sites.  this is not CERN-scale stuff, but being able to configure
large windows on particular routes sounds terribly convenient...

thanks, mark hahn
sharcnet-mcmaster
