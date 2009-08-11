From: "Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu>
Subject: RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Tue, 11 Aug 2009 07:55:04 -0700
Message-ID: <001001ca1a93$b6e50ee0$24af2ca0$@edu>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net> <200908081149.27409.arnd@arndb.de> <0199E0D51A61344794750DC57738F58E6D6AE99743@GVW1118EXC.americas.hpqcorp.net> <200908101707.32751.arnd@arndb.de> <0199E0D51A61344794750DC57738F58E6D6AE99C53@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Stephen Hemminger'" <shemminger@linux-foundation.org>,
	<bridge@lists.linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<virtualization@lists.linux-foundation.org>, <evb@yahoogroups.com>,
	<davem@davemloft.net>, <kaber@trash.net>, <adobriyan@gmail.com>,
	"'Eric Biederman'" <ebiederm@xmission.com>
To: "'Fischer, Anna'" <anna.fischer@hp.com>,
	"'Arnd Bergmann'" <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755182AbZHKOzF@vger.kernel.org>
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D6AE99C53@GVW1118EXC.americas.hpqcorp.net>
Content-Language: en-us
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >
> > The patch from Eric Biederman to allow macvlan to bridge between
> > its slave ports is at
> >
> > http://kerneltrap.org/mailarchive/linux-netdev/2009/3/9/5125774
> 
> Looking through the discussions here, it does not seem as if a decision
> was made to integrate those patches, because they would make the
> macvlan
> interface behave too much like a bridge. Also, it seems as if there was
> still a problem with doing multicast/broadcast delivery when enabling
> local VM-to-VM communication. Is that solved by now?
> 

Also, is there a solution, or plans for a solution, to address macvtap
interfaces that are set to 'promiscuous' mode?  It would seem fairly easy to
support this for interfaces that are simply trying to listen to the port
(e.g. Wireshark).  If the port was being used by something like a firewall
then the VEPA filtering doesn't work too well.

Paul
