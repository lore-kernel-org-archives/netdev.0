From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH v3 00/10] net/macb: driver enhancement concerning GEM
 support, ring logic and cleanup
Date: Tue, 30 Oct 2012 18:31:11 +0100
Message-ID: <CAGhQ9Vw5pw0Hj8hLfADcaO1D3R-f-y8ho35+6YJG+-f2pU_Jrw@mail.gmail.com>
References: <cover.1351591858.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, havard@skinnemoen.net,
	bhutchings@solarflare.com, linux-arm-kernel@lists.infradead.org,
	plagnioj@jcrosoft.com, patrice.vilchez@atmel.com,
	linux-kernel@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1351591858.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30 October 2012 11:17, Nicolas Ferre <nicolas.ferre@atmel.com> wrote:
> This is an enhancement work that began several years ago. I try to catchup with
> some performance improvement that has been implemented then by Havard.
> The ring index logic and the TX error path modification are the biggest changes
> but some cleanup/debugging have been added along the way.
> The GEM revision will benefit from the Gigabit support.
> Newer pinctrl infrastructure support is added but it is optional.
>
> The series has been tested on several Atmel AT91 SoC with the two MACB/GEM
> flavors.

Gave the patch series a quick spin on RM9200 as well and the
at91_ether driver still works. Not many patches here that touch the
shared code though.
So FWIW;
Tested-by: Joachim Eastwood <manabian@gmail.com>

Note: Needed the patch you sent out (net/at91_ether: fix the use of
macb structure) to fix the build error on the struct rename.

regards
Joachim Eastwood
