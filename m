From: jamal <hadi@cyberus.ca>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: 07 Mar 2005 18:50:31 -0500
Message-ID: <1110239430.1043.71.camel@jzny.localdomain>
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
Cc: Eran Mann <emann@mrv.com>, Zdenek Radouch <zdenek@rcn.com>,
        Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@muc.de>,
        Martin Mares <mj@ucw.cz>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
To: Steve Iribarne <steve.iribarne@dilithiumnetworks.com>
In-Reply-To: <422C0B50.20500@mrv.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

BTW, please cc netdev or myself if you are addressing me. This email was
just forwarde by someone else to me - I am not on linux-net. You seem to
have trimmed down the CC list.

On Mon, 2005-03-07 at 18:02:18, Steve Iribarne wrote:
>-> 
>-> What is so wrong with RFC198 addresses??
>-> 

>Really RFC1918 you mean...

Indeed 1918

>Well if your product is placed behind a nat'd network, MOST if not ALL
> nat'd network addresses on the "inside" use the RFC1918 address space.  

I read this a few times and still didnt get it:
Why is it that people using 1918 addresses are affecting you?
Does using 127.x help you because you assume _nobody_ else would be using
127.x addresses? 
I am assuming you want this address for some internal network whereas the 
external contains some routable addresses?

> So I have this working in my products now.  I had to do something a bit
> different in that I want a "special" 127.xx.xx.xx range to be sent out
> on the wire.  So here is what I did.

[..]

Seems you did too much. Look at the 2 liner patch posted by Eran Mann
(which should work on 2.4 and 2.6 as well).

cheers,
jamal
