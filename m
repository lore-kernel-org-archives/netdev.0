From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: About git-bisect (defconfigs)
Date: Wed, 03 Dec 2008 09:50:51 -0800
Message-ID: <4936C6FB.4020201@oracle.com>
References: <bEuTZ-3Ya-5@gated-at.bofh.it> <bECot-57C-1@gated-at.bofh.it>	 <bEFPF-XO-15@gated-at.bofh.it> <bEFPG-XO-19@gated-at.bofh.it>	 <bEG8P-1xl-15@gated-at.bofh.it> <bEGiz-1Hw-11@gated-at.bofh.it>	 <bEGLI-2aS-31@gated-at.bofh.it> <bEGVc-2Bk-11@gated-at.bofh.it>	 <m2r64q6y8e.fsf@gmail.com> <493681B7.20101@diamondcut.com.br> <38b2ab8a0812030924g5391fdbdy15c472a51ab24aef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Renato S. Yamane" <yamane@diamondcut.com.br>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sam Ravnborg <sam@ravnborg.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Francis Moreau <francis.moro@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753570AbYLCRv7@vger.kernel.org>
In-Reply-To: <38b2ab8a0812030924g5391fdbdy15c472a51ab24aef@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francis Moreau wrote:
> On Wed, Dec 3, 2008 at 1:55 PM, Renato S. Yamane
> <yamane@diamondcut.com.br> wrote:
>> Francis Moreau wrote:
>>> Linus Torvalds writes:
>>>> It takes me 16 seconds to compile my kernel (if it's all cached), and
>>>> that's largely because I do _not_ compile one of the crazy distro kernels
>>>> with thousands of totally irrelevant modules for my setup.
>>> an other reason is perhaps you're using a computer that most common
>>> mortal don't have ;)
>>>
>>> Care to share your network configuration ;) ?
>> Maybe a repository with .config files used by linux hard-users (as most
>> developers here) can be very interesting to a lot of people get a starter.
>>
> 
> Or perhaps just to keep 'make defconfig' uptodate with sane core values
> which should fit a desktop config ?
> 
> BTW does anybody what the status of the defconfig files on x86 ?

I looked at them about 1 week ago.  I know that Ingo or the x86 maintainers
team update them occasionally, but I'd like to see a few changes or some
questions answered:

1.  Disable CONFIG_TR.  Token ring is antiquated.  No reason to be in defconfig.

2.  There are several security-related config items that default to =y but the
kconfig help says:  If unsure, say N here.  Like:


CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_KEYS=y
CONFIG_SECURITY=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_SELINUX=y


Maybe I just don't understand the current meaning/usage of defconfig.  eh?


Thanks,
~Randy
