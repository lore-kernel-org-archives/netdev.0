From: john stultz <johnstul@us.ibm.com>
Subject: Re: TSC unstable due to TSC halts in idle?
Date: Fri, 14 May 2010 15:28:31 -0700
Message-ID: <AANLkTimeXEaUnzSBuilbQLHj_oho3ia9EgyPGpB7vJRI@mail.gmail.com>
References: <Pine.LNX.4.64.1005142208290.6220@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Len Brown <len.brown@intel.com>,
	Shaohua Li <shaohua.li@intel.com>, hawk@comx.dk
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1005142208290.6220@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 14, 2010 at 1:13 PM, Jesper Dangaard Brouer <hawk@diku.dk> =
wrote:
> I want to know, if its safe to enable the TSC clocksource, when the
> kernel reports:
> =A0"Marking TSC unstable due to TSC halts in idle"
>
> The system selects HPET (in current_clocksource), but I can still see
> TSC as an available clocksource (in
> /sys/devices/system/clocksource/clocksource0/available_clocksource).
>
> Is it safe to enable TSC manually (by changing current_clocksource)?
> (my workload is 10Git/s routing, cannot survive with a slow clock)
>
>
> Any trick to avoid this? (e.g. kernel config setting, or a /sys/ sett=
ing
> which changes the minimum P-state?)

Might try booting with the max-cstate=3D1 option.

thanks
-john
