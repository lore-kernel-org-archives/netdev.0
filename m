From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath6kl: sdio: fix system panic when doing wifi stress test
Date: Sat, 8 Mar 2014 13:57:36 +0200
Message-ID: <87a9d0oqbz.fsf@kamboji.qca.qualcomm.com>
References: <1384221185-8645-1-git-send-email-r64343@freescale.com>
	<87k3fvjvjg.fsf@kamboji.qca.qualcomm.com>
	<AD13664F485EE54694E29A7F9D5BE1AFC0AD96@039-SN2MPN1-022.039d.mgd.msft.net>
	<20140307093813.GA28728@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Hui Liu <Hui.Liu@freescale.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<ath6kl@lists.infradead.org>
To: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140307093813.GA28728@pengutronix.de> (Steffen Trumtrar's
	message of "Fri, 7 Mar 2014 10:38:13 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Steffen,

Steffen Trumtrar <s.trumtrar@pengutronix.de> writes:

>> > Does the patch below help? It would also fix the corruption with
>> > scat_q_depth. Please note that I have only compile tested it. And I might
>> > have also missed something important, so please review it carefully.
>> 
>> Yes, Firstly, I have looked at the asm code and the compiler(gcc 4.8.1) works correctly after applying
>> the following patch. Secondly, I have tested the patch with compiler(gcc 4.8.1) on the real HW, and it
>> works fine too. Without the patch, the kernel crash will happen 100%.
>> 
>> Thus, for the patch:
>> 
>> Acked-by: Jason Liu <r64343@freescale.com>
>> Tested-by: Jason Liu <r64343@freescale.com>

[...]

> What happend with this? If I look in mainline, I don't find it. At
> least the reording of the struct fields looks as if one definitely
> wants to have that.

It seems that I forgot to submit this properly, sorry about that. I did
it now:

http://lists.infradead.org/pipermail/ath6kl/2014-March/000000.html

-- 
Kalle Valo
