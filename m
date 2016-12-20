From: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Tue, 20 Dec 2016 09:21:34 -0800
Message-ID: <20161220172134.GJ4920@atomide.com>
References: <201611111820.52072@pali>
 <201612181204.52928@pali>
 <83b2e9a4-f990-68a8-241e-375e46448d47@broadcom.com>
 <201612181309.01298@pali>
 <fd180271-1cd4-9891-e3d5-ae9cd0fb088b@broadcom.com>
 <87shpiu8j8.fsf@kamboji.qca.qualcomm.com>
 <20161220165658.GI4920@atomide.com>
 <87bmw6ttim.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>,
        "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>,
        Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TasMV2rI37PzA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87bmw6ttim.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> [161220 09:12]:
> Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org> writes:
> 
> > * Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> [161220 03:47]:
> >> Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> writes:
> >> 
> >> > On 18-12-2016 13:09, Pali Rohár wrote:
> >> >
> >> >> File wl1251-nvs.bin is provided by linux-firmware package and contains 
> >> >> default data which should be overriden by model specific calibrated 
> >> >> data.
> >> >
> >> > Ah. Someone thought it was a good idea to provide the "one ring to rule
> >> > them all". Nice.
> >> 
> >> Yes, that was a bad idea. wl1251-nvs.bin in linux-firmware.git should be
> >> renamed to wl1251-nvs.bin.example, or something like that, as it should
> >> be only installed to a real system only if there's no real calibration
> >> data available (only for developers to use, not real users).
> >
> > Makes sense to me. Note that with the recent changes to wlcore, we can
> > now easily provide board specific calibration firmware simply by adding a
> > new compatible value. So for n900, we could have something like
> > compatible = "ti,wl1251-n900" and have it point to n900 specific calibration
> > file wl1251-nvs-n900.bin. Of course this won't help with the mac address,
> > or any of the device specific data..
> >
> > That is assuming the calibration values are the same for each similar
> > device and don't have to be generated for each device. And naturally wl1251
> > needs simlar changes done to make use of devices specific calibration files.
> 
> No, these are unique per each sold device. Every N900 was calibrated at
> the factory and they all have different calibration data which is stored
> to the flash. So when N900 boots (and in _every_ boot) it has to load
> the calibration data from the flash and provide it to the wl1251 driver
> somehow.

Urgh, OK. So much for that idea then.

Thanks,

Tony
