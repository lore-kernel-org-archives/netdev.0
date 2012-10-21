From: Borislav Petkov <bp@alien8.de>
Subject: Re: Re: Re: Re: Re: A reliable kernel panic (3.6.2) and system crash
 when visiting a particular website
Date: Sun, 21 Oct 2012 19:03:15 +0200
Message-ID: <20121021170315.GB20642@liondog.tnic>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05>
 <20121020162759.GA12551@liondog.tnic>
 <966148591.30347.1350754909449.JavaMail.mail@webmail08>
 <20121020203227.GC555@elf.ucw.cz>
 <20121020225849.GA8976@liondog.tnic>
 <1781795634.31179.1350774917965.JavaMail.mail@webmail04>
 <20121021002424.GA16247@liondog.tnic>
 <1798605268.19162.1350784641831.JavaMail.mail@webmail17>
 <20121021110851.GA6504@liondog.tnic>
 <121566322.100103.1350820776893.JavaMail.mail@webmail20>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: pavel@ucw.cz, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, linux-media@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <121566322.100103.1350820776893.JavaMail.mail@webmail20>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 21, 2012 at 11:59:36AM +0000, Artem S. Tashkinov wrote:
> http://imageshack.us/a/img685/9452/panicz.jpg
> 
> list_del corruption. prev->next should be ... but was ...

Btw, this is one of the debug options I told you to enable.

> I cannot show you more as I have no serial console to use :( and the kernel
> doesn't have enough time to push error messages to rsyslog and fsync
> /var/log/messages

I already told you how to catch that oops: boot with "pause_on_oops=600"
on the kernel command line and photograph the screen when the first oops
happens. This'll show us where the problem begins.

-- 
Regards/Gruss,
    Boris.
