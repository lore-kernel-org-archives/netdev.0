From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] net-qmi_wwan: Delete an unnecessary variable
 initialisation in qmi_wwan_register_subdriver()
Date: Sat, 02 Jan 2016 20:45:35 -0500 (EST)
Message-ID: <20160102.204535.816844219039778167.davem@davemloft.net>
References: <5686AE52.1020008@users.sourceforge.net>
	<5686AFAE.7020401@users.sourceforge.net>
	<87ziwnpt2v.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, julia.lawall-L2FTfq7BK8M@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87ziwnpt2v.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Sat, 02 Jan 2016 22:30:48 +0100

> SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org> writes:
>=20
>> From: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
>> Date: Fri, 1 Jan 2016 17:35:03 +0100
>>
>> Omit explicit initialisation at the beginning for one local variable
>> that is redefined before its first use.
>=20
>=20
> This patch is unnecessary. The variable initialisation is redundant.
> See the difference?  Sending an unnecessary patch causes unnecessary
> load on reviewers and maintainers.  Keeping redundant code has no
> measurable cost, and can save the same maintainers a lot of trouble
> later.

+1

I'm getting really tired of these changes.  And a lot of them are
coming in right now...
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
