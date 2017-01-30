From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Mon, 30 Jan 2017 09:53:09 -0800
Message-ID: <20170130175309.GY7403@atomide.com>
References: <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
 <20170127101043.GD24223@pali>
 <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
 <20170127103408.GG24223@pali>
 <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
 <20170127115706.GH24223@pali>
 <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
 <20170127131146.GI24223@pali>
 <87bmus5xyc.fsf@kamboji.qca.qualcomm.com>
 <20170127194012.GE20571@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170127194012.GE20571@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Pavel Machek <pavel@ucw.cz> [170127 11:41]:
> On Fri 2017-01-27 17:23:07, Kalle Valo wrote:
> > Pali Rohár <pali.rohar@gmail.com> writes:
> > 
> > > On Friday 27 January 2017 14:26:22 Kalle Valo wrote:
> > >> Pali Rohár <pali.rohar@gmail.com> writes:
> > >> 
> > >> > 2) It was already tested that example NVS data can be used for N900 e.g.
> > >> > for SSH connection. If real correct data are not available it is better
> > >> > to use at least those example (and probably log warning message) so user
> > >> > can connect via SSH and start investigating where is problem.
> > >> 
> > >> I disagree. Allowing default calibration data to be used can be
> > >> unnoticed by user and left her wondering why wifi works so badly.
> > >
> > > So there are only two options:
> > >
> > > 1) Disallow it and so these users will have non-working wifi.
> > >
> > > 2) Allow those data to be used as fallback mechanism.
> > >
> > > And personally I'm against 1) because it will break wifi support for
> > > *all* Nokia N900 devices right now.
> > 
> > All two of them? :)
> 
> Umm. You clearly want a flock of angry penguins at your doorsteps :-).

Well this silly issue of symlinking and renaming nvs files in a standard
Linux distro was also hitting me on various devices with wl12xx/wl18xx
trying to use the same rootfs.

Why don't we just set a custom compatible property for n900 that then
picks up some other nvs file instead of the default?

Regards,

Tony
