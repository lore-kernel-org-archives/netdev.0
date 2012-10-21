From: Daniel Mack <zonque@gmail.com>
Subject: Re: A reliable kernel panic (3.6.2) and system crash when visiting
 a particular website
Date: Sun, 21 Oct 2012 21:54:51 +0200
Message-ID: <5084530B.6030209@gmail.com>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05> <20121020162759.GA12551@liondog.tnic> <966148591.30347.1350754909449.JavaMail.mail@webmail08> <20121020203227.GC555@elf.ucw.cz> <20121020225849.GA8976@liondog.tnic> <1781795634.31179.1350774917965.JavaMail.mail@webmail04> <20121021002424.GA16247@liondog.tnic> <1798605268.19162.1350784641831.JavaMail.mail@webmail17> <20121021110851.GA6504@liondog.tnic> <121566322.100103.1350820776893.JavaMail.mail@webmail20> <20121021170315.GB20642@liondog.tnic> <1906833625.122006.1350848941352.JavaMail.mail@webmail16>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bp@alien8.de, pavel@ucw.cz, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, security@kernel.org,
	linux-media@vger.kernel.org, linux-usb@vger.kernel.org,
	alsa-devel@alsa-project.org, stern@rowland.harvard.edu
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1906833625.122006.1350848941352.JavaMail.mail@webmail16>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.10.2012 21:49, Artem S. Tashkinov wrote:
>>
>> On Oct 21, 2012, Borislav Petkov <bp@alien8.de> wrote: 
>>
>> On Sun, Oct 21, 2012 at 11:59:36AM +0000, Artem S. Tashkinov wrote:
>>> http://imageshack.us/a/img685/9452/panicz.jpg
>>>
>>> list_del corruption. prev->next should be ... but was ...
>>
>> Btw, this is one of the debug options I told you to enable.
>>
>>> I cannot show you more as I have no serial console to use :( and the kernel
>>> doesn't have enough time to push error messages to rsyslog and fsync
>>> /var/log/messages
>>
>> I already told you how to catch that oops: boot with "pause_on_oops=600"
>> on the kernel command line and photograph the screen when the first oops
>> happens. This'll show us where the problem begins.
> 
> This option didn't have any effect, or maybe it's because it's such a serious crash
> the kernel has no time to actually print an ooops/panic message.
> 
> dmesg messages up to a crash can be seen here: https://bugzilla.kernel.org/attachment.cgi?id=84221

Nice. Could you do that again with the patch applied I sent yo some
hours ago?


Thanks,
Daniel
