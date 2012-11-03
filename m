From: Daniel Mack <zonque@gmail.com>
Subject: Re: A reliable kernel panic (3.6.2) and system crash when visiting
 a particular website
Date: Sat, 03 Nov 2012 15:16:36 +0100
Message-ID: <50952744.4090203@gmail.com>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05> <20121020162759.GA12551@liondog.tnic> <966148591.30347.1350754909449.JavaMail.mail@webmail08> <20121020203227.GC555@elf.ucw.cz> <20121020225849.GA8976@liondog.tnic> <1781795634.31179.1350774917965.JavaMail.mail@webmail04> <20121103141049.GA24238@edge.cmeerw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, pavel@ucw.cz,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, linux-media@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Christof Meerwald <cmeerw@cmeerw.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121103141049.GA24238@edge.cmeerw.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03.11.2012 15:10, Christof Meerwald wrote:
> On Sat, 20 Oct 2012 23:15:17 +0000 (GMT), Artem S. Tashkinov wrote:
>> It's almost definitely either a USB driver bug or video4linux driver bug:
>>
>> I'm CC'ing linux-media and linux-usb mailing lists, the problem is described here:
>> https://lkml.org/lkml/2012/10/20/35
>> https://lkml.org/lkml/2012/10/20/148
> 
> Not sure if it's related, but I am seeing a kernel freeze with a
> usb-audio headset (connected via an external USB hub) on Linux 3.5.0
> (Ubuntu 12.10) - see

Does Ubuntu 12.10 really ship with 3.5.0? Not any more recent

> http://comments.gmane.org/gmane.comp.voip.twinkle/3052 and
> http://pastebin.com/aHGe1S1X for a self-contained C test.

Some questions:

 - Are you seeing the same issue with 3.6.x?
 - If you can reproduce this issue, could you paste the messages in
dmesg when this happens? Do they resemble to the list corruption that
was reported?
 - Do you see the same problem with 3.4?
 - Are you able to apply the patch Alan Stern posted in this thread earlier?

We should really sort this out, but I unfortunately lack a system or
setup that shows the bug.


Thanks,
Daniel
