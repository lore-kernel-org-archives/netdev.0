From: Zdenek Radouch <zdenek@rcn.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Mon, 07 Mar 2005 22:15:03 -0500
Message-ID: <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
References: <422C0B50.20500@mrv.com>
 <m1y8d0mss2.fsf@muc.de>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>
 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>
 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com> <1110239430.1043.71.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
        Andi Kleen <ak@muc.de>, Martin Mares <mj@ucw.cz>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
To: hadi@cyberus.ca, Steve Iribarne <steve.iribarne@dilithiumnetworks.com>
In-Reply-To: <1110239430.1043.71.camel@jzny.localdomain>
References: <422C0B50.20500@mrv.com>
 <m1y8d0mss2.fsf@muc.de>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>
 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>
 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 06:50 PM 3/7/05 -0500, jamal wrote:
>BTW, please cc netdev or myself if you are addressing me. This email was
>just forwarde by someone else to me - I am not on linux-net. You seem to
>have trimmed down the CC list.
>
>On Mon, 2005-03-07 at 18:02:18, Steve Iribarne wrote:
>>-> 
>>-> What is so wrong with RFC198 addresses??
>>-> 
>
>>Really RFC1918 you mean...
>
>Indeed 1918
>
>>Well if your product is placed behind a nat'd network, MOST if not ALL
>> nat'd network addresses on the "inside" use the RFC1918 address space.  
>
>I read this a few times and still didnt get it:
>Why is it that people using 1918 addresses are affecting you?

RFC 1918 trivializes the IP addressing by boxing
all hosts into either a "private" or "public" category,
based on their need to access the Internet.

The major thing the RFC misses is the fact that internal
to one of these "public" or "private" hosts, you may have
another, "even more private" network, for example one
that connects the cards within the chassis.  Such network
must be (for obvious reasons) completely hidden
from the outside, and thus cannot come from the
"outside" address space.  This "outside" space is a union
of the "public" and "private" IP addresses.
Guess what's left?  How 'bout 127.0.0.0.

-Z
