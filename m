From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [-next] Regression: ssh log in slowdown
Date: Sun, 15 Jun 2014 10:42:57 +0200
Message-ID: <CAMuHMdV+wjdEqKANwu4b=LX1t6X8dhfZKdyCkWB-9KXztPmNhg@mail.gmail.com>
References: <alpine.DEB.2.02.1406130829370.23090@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1406130829370.23090@tomh.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tom,

On Fri, Jun 13, 2014 at 5:37 PM, Tom Herbert <therbert@google.com> wrote:
>> Thanks, I applied the series "[PATCH 0/4] Checksum fixes", and the fix
>> above, but it doesn't help.
>>
>> Note that I'm also using NFS root, which doesn't seem to be affected.
>> I can happily run "ls -R /" on the serial console during the 10 s delay
> in ssh.
>
> Can you try one more patch below with the series applied? Also, can you

This patch fixes the issue. Thanks!

> look at 'netstat -s' to see if UDP checksum errors are being reported.

Indeed, errors are reported under Udp/InCsumErrors.
With this new patch, no errors are reported.

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
