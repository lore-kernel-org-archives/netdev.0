From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v2 0/8] Drop support for Renesas H8/300 architecture
Date: Mon, 02 Sep 2013 20:26:16 -0700
Message-ID: <522556D8.803@roeck-us.net>
References: <1377906694-9578-1-git-send-email-linux@roeck-us.net> <52254F11.8070601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org, linux-watchdog@vger.kernel.org,
	Wim Van Sebroeck <wim@iguana.be>,
	"David S. Miller" <davem@davemloft.net>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Paris <eparis@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiang Liu <jiang.liu@huawei.com>,
	David Howells <dhowells@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Linus Walleij <linus.walleij@linaro.org>
To: Chen Gang F T <chen.gang.flying.transformer@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52254F11.8070601@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/02/2013 07:53 PM, Chen Gang F T wrote:
> Hello Guenter Roeck:
> 
> 
> I don't care about whether I am in cc mailing list, but at least,
> please help confirm 2 things:
> 
>    Is what I had done for h8300 just making wastes and noisy in kernel and related sub-system mailing list ?
> 
>    and is the disccusion about h8300 between us also wastes and noisy in kernel mailing list ?
> 

It raised my awareness of the status of h8300 maintenance,
so I would not see it as noise or waste. I might have suggested
a different target for your efforts, but that is your choice to make,
not mine.

On the code review side, I had suggested that you should not add new
ifdefs into code, much less unnecessary ones. Your counter-argument
was that you wanted to follow the existing coding style in the file
in question. To me, that argument is along the line of "the coding
style in this file is bad, let's do more of it".
That doesn't make much sense to me, so I did not bother to respond.
Setting that aside, it is not up to me to approve or reject your patches.
Whoever does that would be the one you have to convince.

Guenter
