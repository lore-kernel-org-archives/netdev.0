From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Wed, 17 May 2017 15:22:30 +0200
Message-ID: <1495027350.2442.12.camel@sipsolutions.net>
References: <0fd90416-f33c-a6be-14fd-5e964583e9cb@broadcom.com>
         <20170515231339.GF17314@wotan.suse.de>
         <1495022766.2442.1.camel@sipsolutions.net> <20170517125335.GG10015@pali>
         <1495026290.2442.6.camel@sipsolutions.net> <20170517132131.GH10015@pali>
         (sfid-20170517_152143_910249_81751B88)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Pavel Machek <pavel@ucw.cz>, Daniel Wagner <wagi@monom.org>,
        Tom Gundersen <teg@jklm.no>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Takashi Iwai <tiwai@suse.de>,
        AKASHI Takahiro <takahiro.akashi@linaro.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org,
        =?UTF-8?
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517132131.GH10015@pali> (sfid-20170517_152143_910249_81751B88)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-05-17 at 15:21 +0200, Pali Rohár wrote:
> On Wednesday 17 May 2017 15:04:50 Johannes Berg wrote:
> > On Wed, 2017-05-17 at 14:53 +0200, Pali Rohár wrote:
> > 
> > > > In fact, why should the *driver* care either? IOW - why should
> > > > "request_firmware_prefer_user()" even exist?
> > > 
> > > There are default/example NVS data, which are stored in
> > > /lib/firmware
> > > and installed by linux-firmware package.
> > 
> > [...]
> > 
> > Oh, so you're saying you want this to invert the order ... Ok, that
> > makes some sense.
> 
> Yes! I thought that this fact can be understood from commit message.
> If not, I can change it, but provide how to improve it.

It probably can, I was only Cc'ed later :)

Sorry for the noise.

johannes
