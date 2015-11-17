From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2 net-next] net/core: ensure features get disabled on new
 lower devs
Date: Tue, 17 Nov 2015 11:04:17 +0100
Message-ID: <CAMuHMdWZQfBM-KKUEHnz89D82pBsLtcFuabrqj504tFcnOz9yg@mail.gmail.com>
References: <1446583017-19021-1-git-send-email-jarod@redhat.com>
	<1446610172-21420-1-git-send-email-jarod@redhat.com>
	<20151104.215632.964832400121049446.davem@davemloft.net>
	<56452E2A.9050501@gmail.com>
	<CAMuHMdWHLmfB3hEfwOCkHMrHPOBt-xk2S95Tq1yyH1bwk29DNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Jarod Wilson <jarod@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWHLmfB3hEfwOCkHMrHPOBt-xk2S95Tq1yyH1bwk29DNA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 17, 2015 at 10:02 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> On Fri, Nov 13, 2015 at 1:26 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 04/11/15 18:56, David Miller wrote:
>>>> Fixes: fd867d51f889 ("net/core: generic support for disabling netdev features down stack")
>>>  ...
>>>> Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>> Signed-off-by: Jarod Wilson <jarod@redhat.com>
>>>> ---
>>>> v2: Based on suggestions from Alex, and with not changing err to ret, this
>>>> patch actually becomes quite minimal and doesn't ugly up the code much.
>>>
>>> Applied, thanks.
>>
>> This causes some warnings to be displayed for DSA stacked devices:
>
> And a few more:
>
> sh-eth ee700000.ethernet eth0: set_features() failed (-1); wanted
> 0x0000000000004000, left 0x0000000000004800
> g_ether gadget usb0: set_features() failed (-1); wanted
> 0x0000000000004000, left 0x0000000000004800

smsc911x 8000000.ethernet eth0: set_features() failed (-1); wanted
0x0000000000004000, left 0x0000000000004800

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
