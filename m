From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Tue, 8 Mar 2005 19:34:05 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0503081928490.5332@filer.marasystems.com>
References: <422C0B50.20500@mrv.com> <m1y8d0mss2.fsf@muc.de>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>  <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
  <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>  <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
  <20050306173145.GQ31837@postel.suug.ch>  <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>  <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>  <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
 <1110288879.1050.167.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Zdenek Radouch <zdenek@rcn.com>,
	Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, Martin Mares <mj@ucw.cz>,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1110288879.1050.167.camel@jzny.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Mar 2005, jamal wrote:

> Lets see, your requirements are:
> a) packets within a chasis subnet shall stay within a chasis subnet
> b) the outside (of the chasis) world shall never discover whats inside
> the chasis (example ARPs will fail to resolve etc)

> Did i miss anything else?

Yes.

c) The chassis components must interact properly with other external 
equipment using public or RFC1918 addresses.


So while yes, it may be possible to use RFC1918 addresses, but only if the 
network administrator connecting the chassi first enters a RFC1918 network 
he has reserved for "equipment internal" use into the chassis 
configuration to ensure the internal addressing within the chassis does 
not conflict with the addressing used on his private network. This even if 
these addresses is never seen anywhere outside of the chassis (except 
possibly diagnostics channels into the chassis).

Regards
Henrik
