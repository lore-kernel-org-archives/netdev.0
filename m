From: "M. Warner Losh" <imp-uzTCJ5RojNnQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 09:35:21 -0600 (MDT)
Message-ID: <20100827.093521.467748298504420477.imp@bsdimp.com>
References: <20100827075727.GA3818@riccoc20.at.omicron.at>
	<20100827134154.50eef56c@lxorguk.ukuu.org.uk>
	<20100827140205.GA3293@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: giometti-k2GhghHVRtY@public.gmane.org, johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org
To: richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20100827140205.GA3293-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

In message: <20100827140205.GA3293-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
            Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
: On Fri, Aug 27, 2010 at 01:41:54PM +0100, Alan Cox wrote:
: > > The master node in a PTP network probably takes its time from a
: > > precise external time source, like GPS. The GPS provides a 1 PPS
: > > directly to the PTP clock hardware, which latches the PTP hardware
: > > clock time on the PPS edge. This provides one sample as input to a
: > > clock servo (in the PTPd) that, in turn, regulates the PTP clock
: > > hardware.
: > 
: > A PTP clock is TAI, Unix time is UTC.
: 
: But TAI and UTC progress at the same rate, and UTC differs from TAI by
: a constant offset. In fact, the needed conversion is provided by the
: protocol, so it is not hard to take a 1 PPS from GPS and set the PTP
: clock to TAI.

Except for leap seconds, this is true.   However, Unix time isn't UTC
either.  Unix time is UTC that pretends leap seconds just don't
exist.  POSIX enshrined this long ago, and nobody is going to change
that any time soon.

I don't believe IEEEv2 propagates leap seconds, does it?

Warner
