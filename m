From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Fri, 16 Dec 2016 08:25:44 +0100
Message-ID: <07be7fc8-6c7f-6e03-379d-fa781b248259@monom.org>
References: <201611111820.52072@pali> <201611241749.33681@pali>
 <20161124181138.4i6ehkpohjxfgpbn@earth> <201611241935.32796@pali>
 <87d1gtli57.fsf@purkki.adurom.net> <1481816017.2090.2.camel@Pali-Nokia-N900>
 <76365770-f5ba-9565-3fca-710518f64d81@broadcom.com>
 <CAB=NE6VHF+U7DzapENvLMKtN4Dgi9J0qMoeUJ8o4vSwc2-rRFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>,
        Josh Boyer <jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
        Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>,
        Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAB=NE6VHF+U7DzapENvLMKtN4Dgi9J0qMoeUJ8o4vSwc2-rRFQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/16/2016 03:03 AM, Luis R. Rodriguez wrote:
> For the new API a solution for "fallback mechanisms" should be clean
> though and I am looking to stay as far as possible from the existing
> mess. A solution to help both the old API and new API is possible for
> the "fallback mechanism" though -- but for that I can only refer you
> at this point to some of Daniel Wagner and Tom Gunderson's firmwared
> deamon prospect. It should help pave the way for a clean solution and
> help address other stupid issues.

The firmwared project is hosted here

https://github.com/teg/firmwared

As Luis pointed out, firmwared relies on FW_LOADER_USER_HELPER_FALLBACK, 
which is not enabled by default. I don't see any reason why firmwared 
should not also support loading calibration data. If we find a sound way 
to do this.

As you can see from the commit history it is a pretty young project and 
more ore less reanimation of the old udev firmware loader feature.  We 
are getting int into shape, adding integration tests etc.

The main motivation for this project is the get movement back in stuck 
discussion on the firmware loader API. Luis was very busy writing up all 
the details on the current situation and purely from the amount of 
documentation need to describe the API you can tell something is awry.

Thanks,
Daniel
