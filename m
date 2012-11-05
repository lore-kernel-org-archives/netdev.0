From: Christof Meerwald <cmeerw@cmeerw.org>
Subject: Re: A reliable kernel panic (3.6.2) and system crash when visiting a
 particular website
Date: Mon, 5 Nov 2012 20:13:36 +0100
Message-ID: <20121105191336.GA1404@edge.cmeerw.net>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05>
 <20121020162759.GA12551@liondog.tnic>
 <966148591.30347.1350754909449.JavaMail.mail@webmail08>
 <20121020203227.GC555@elf.ucw.cz>
 <20121020225849.GA8976@liondog.tnic>
 <1781795634.31179.1350774917965.JavaMail.mail@webmail04>
 <20121103141049.GA24238@edge.cmeerw.net>
 <50952744.4090203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, pavel@ucw.cz,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, linux-media@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50952744.4090203@gmail.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 03, 2012 at 03:16:36PM +0100, Daniel Mack wrote:
> On 03.11.2012 15:10, Christof Meerwald wrote:
> > http://comments.gmane.org/gmane.comp.voip.twinkle/3052 and
> > http://pastebin.com/aHGe1S1X for a self-contained C test.
> Some questions:
> 
>  - Are you seeing the same issue with 3.6.x?

I haven't tried it myself, but the other poster on
http://comments.gmane.org/gmane.comp.voip.twinkle/3052 mentions 3.6.2
(and 3.6.3)

>  - If you can reproduce this issue, could you paste the messages in
> dmesg when this happens? Do they resemble to the list corruption that
> was reported?

I am not seeing any kernel messages at all - the system just freezes
and not even the SysRq stuff works after that.

>  - Do you see the same problem with 3.4?

I upgraded from Ubuntu 12.04 (Linux 3.2) where I didn't see the
problem. However,
http://www.linuxquestions.org/questions/linux-desktop-74/twinkle-causes-linux-freeze-kernel-3-6-2-a-4175433799/
mentions 3.4.0

>  - Are you able to apply the patch Alan Stern posted in this thread earlier?

Unfortunately, I am not really in a position to apply kernel patches
at the moment.


> We should really sort this out, but I unfortunately lack a system or
> setup that shows the bug.

BTW, I have been able to reproduce the problem on a completely
different machine (also running Ubuntu 12.10, but different hardware).
The important thing appears to be that the USB audio device is
connected via a USB 2.0 hub (and then using the test code posted in
http://pastebin.com/aHGe1S1X specifying the audio device as
"plughw:Set" (or whatever it's called) seems to trigger the freeze).

So I guess another question is: do you have a USB headset connected
via a USB 2.0 hub and not seeing the problem or is your USB headset
not connected via a USB 2.0 hub? (of course, it would also be useful
if others could comment if they are seeing the problem with that setup
or not)


Christof

-- 

http://cmeerw.org                              sip:cmeerw at cmeerw.org
mailto:cmeerw at cmeerw.org                   xmpp:cmeerw at cmeerw.org
