From: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v2 next-next] net: hns: enet specifies a reference to
 dsaf
Date: Wed, 20 Jan 2016 11:36:10 +0200
Message-ID: <1453282570.2521.130.camel@linux.intel.com>
References: <1452654880-28980-1-git-send-email-yankejian@huawei.com>
	 <56970F48.9060504@huawei.com> <1452764635.2521.28.camel@linux.intel.com>
	 <569F2DEC.9040209@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: "Yankejian (Hackim Yim)" <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Yisen Zhuang <Yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
	fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <569F2DEC.9040209-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-01-20 at 14:49 +0800, Yankejian (Hackim Yim) wrote:
> > > +
> > > > > > +	snprintf(ae_dev->name, AE_NAME_SIZE, "%s%d",
> > > > > > DSAF_DEVICE_NAME,
> > > > > > +		=C2=A0(int)atomic_inc_return(&id));
> > If you bind/unbind device enough times you may get an overflow and
> > end
> > up with name of existing device (if you have 1+ of them in the
> > system).
> >=20
> > To avoid such situation better to use IDA/IDR framework.
> >=20
> Hi, Andy
> Thanks again for your suggestion.
> It seems that using IDA/IDR framework is better, but all of the
> functions must be serialized by lock.

AFAIR it's designed in a way you don't need to do any additional
locking or synchronization.

--=20
Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Intel Finland Oy

--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
