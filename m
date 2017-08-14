From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: Re: [PATCH 000/102] Convert drivers to explicit reset API
Date: Mon, 14 Aug 2017 09:36:38 +0200
Message-ID: <1502696198.2287.7.camel@pengutronix.de>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
         <20170719211515.46a1196c@windsurf>
         <1500543415.2354.37.camel@pengutronix.de>
         <20170720123640.43c2ce01@windsurf>
         <1500555312.2354.75.camel@pengutronix.de>
         <CAKdAkRTx8jd8UToz5_EgMmdW3V47i2uo++YvVB_yzytqSA=P1Q@mail.gmail.com>
         <CACRpkdaXOv7mX+b-q1K34CB5w0SWPXCKa21wHaxL7qjf91PJXQ@mail.gmail.com>
         <1500885221.2391.50.camel@pengutronix.de>
         <20170812114357.v4ru75dw5hq7wemx@ninjato>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Walleij <linus.walleij@linaro.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Prashant Gaikwad <pgaikwad@nvidia.com>,
        Heiko Stuebner <heiko@sntech.de>,
        Peter Chen <Peter.Chen@nxp.com>,
        DRI <dri-devel@lists.freedesktop.org>,
        Marc Dietrich <marvin24@gmx.de>,
        Rakesh Iyer <riyer@nvidia.com>,
        Peter Meerwald-Stadler <pmeerw@pmeerw.net>,
        linux-clk <linux-clk@vger.kernel.org>,
        Wim Van Sebroeck <wim@iguana.be>,
        Xinliang Liu <z.liuxinliang@hisilicon.com>,
        Chanwoo Choi <cw00.choi@samsung.com>,
        Alan Stern <stern@rowland.harvard.edu>,
        Jiri Slaby <jslaby@suse.com>,
        Michael Turquette <mturquette@baylibre.com>,
        Guenter R
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170812114357.v4ru75dw5hq7wemx@ninjato>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Sat, 2017-08-12 at 13:43 +0200, Wolfram Sang wrote:
> > Thanks for the hint and the references. It seems this turned out
> > okay,
> > but I wouldn't dare to introduce such macro horror^Wmagic.
> > I'd rather have all users converted to the _exclusive/_shared
> > function
> > calls and maybe then replace the internal __reset_control_get with
> > Thomas' suggestion.
> 
> I didn't follow the discussion closely. Shall I still apply the i2c
> patches?

Yes, please.

regards
Philipp
