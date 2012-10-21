From: Daniel Mack <zonque@gmail.com>
Subject: Re: A reliable kernel panic (3.6.2) and system crash when visiting
 a particular website
Date: Sun, 21 Oct 2012 14:12:24 +0200
Message-ID: <5083E6A8.3050003@gmail.com>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05> <20121020162759.GA12551@liondog.tnic> <966148591.30347.1350754909449.JavaMail.mail@webmail08> <20121020203227.GC555@elf.ucw.cz> <20121020225849.GA8976@liondog.tnic> <1781795634.31179.1350774917965.JavaMail.mail@webmail04> <20121021002424.GA16247@liondog.tnic> <1798605268.19162.1350784641831.JavaMail.mail@webmail17> <20121021110851.GA6504@liondog.tnic> <121566322.100103.1350820776893.JavaMail.mail@webmail20>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bp@alien8.de, pavel@ucw.cz, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, security@kernel.org,
	linux-media@vger.kernel.org, linux-usb@vger.kernel.org
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <121566322.100103.1350820776893.JavaMail.mail@webmail20>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.10.2012 13:59, Artem S. Tashkinov wrote:
> On Oct 21, 2012, Borislav Petkov wrote:
>>
>> On Sun, Oct 21, 2012 at 01:57:21AM +0000, Artem S. Tashkinov wrote:
>>> The freeze happens on my *host* Linux PC. For an experiment I decided
>>> to check if I could reproduce the freeze under a virtual machine - it
>>> turns out the Linux kernel running under it also freezes.
>>
>> I know that - but a freeze != oops - at least not necessarily. Which
>> means it could very well be a different issue now that vbox is gone.
>>
>> Or, it could be the same issue with different incarnations: with vbox
>> you get the corruptions and without it, you get the freezes. I'm
>> assuming you do the same flash player thing in both cases?
>>
>> Here's a crazy idea: can you try to reproduce it in KVM?
> 
> OK, dismiss VBox altogether - it has a very buggy USB implementation, thus
> it just hangs when trying to access my webcam.
> 
> What I've found out is that my system crashes *only* when I try to enable
> usb-audio (from the same webcam)

It would also be interesting to know whether you have problems with
*only* the video capture, with some tool like "cheese". It might be
you're hitting a host controller issue here, and then isochronous input
packets on the video interface would most likely also trigger such am
effect. Actually, knowing whether that's the case would be crucial for
further debugging.


Daniel
