From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Thu, 10 Mar 2005 11:10:07 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0503101102340.26065@filer.marasystems.com>
References: <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net> <20050306173145.GQ31837@postel.suug.ch>
 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de>
 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net> <422C0B50.20500@mrv.com>
 <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net> <1110288879.1050.167.camel@jzny.localdomain>
 <20050308135134.GA20607@atrey.karlin.mff.cuni.cz> <1110290300.1050.190.camel@jzny.localdomain>
 <20050308140301.GC20607@atrey.karlin.mff.cuni.cz> <1110291470.1043.211.camel@jzny.localdomain>
 <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com>
 <1110316631.1084.57.camel@jzny.localdomain> <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com>
 <E1D91Rz-0004wp-00@smtp01.mrf.mail.rcn.net> <1110377889.1090.124.camel@jzny.localdomain>
 <d0n98a$icn$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <d0n98a$icn$1@sea.gmane.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Mar 2005, Jason Lunz wrote:

> interfaces. I don't know whether policy routing gives enough control to
> do this in a general fashion;

Not easily. The problem is to determine which path packets you send should 
take if the destination is on both sides.

You can do some magics with connection tracking and CONNMARK and magic 
routing tables infront of the local table and disabling the martian 
checks, but not everything can be solved in this manner.

Regards
Henrik
