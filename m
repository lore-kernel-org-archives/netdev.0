From: jamal <hadi@cyberus.ca>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: 07 Mar 2005 07:14:44 -0500
Message-ID: <1110197684.1087.1251.camel@jzny.localdomain>
References: <m1y8d0mss2.fsf@muc.de>
	 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
	 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
	 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
	 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
	 <20050306173145.GQ31837@postel.suug.ch>
	 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de>
	 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>  <422C0B50.20500@mrv.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zdenek Radouch <zdenek@rcn.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, Martin Mares <mj@ucw.cz>,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Eran Mann <emann@mrv.com>
In-Reply-To: <422C0B50.20500@mrv.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-07 at 03:05, Eran Mann wrote:
> Zdenek Radouch wrote:
> ...
> > 
> > 2) If it does require kernel hacking, would you like to do it for me?
> >     (as I had said, as a contract)
> I think what Andi Kleen was talking about below is something like the 
> attached 5 minutes patch (applies cleanly to 2.4.2x kernels I have at 
> hand, and to 2.6.11 with minor offset). Please donate the 5 minute wages 
> to the OSDL or the FSF at your choice ;-)

That should do it. Or you can even return false in the macro always for
his case - since he will never have a lo device.

However, using these addresses is a BAD BAD idea. A lot of other
machines will be expecting 127.x to mean something speacial. I dont
think you should ask the poster for wages, he will suffer enough with
ARPs etc ;-> 

What is so wrong with RFC198 addresses??

cheers,
jamal

