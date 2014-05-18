From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats using ethtool
Date: Sun, 18 May 2014 16:50:30 +0200
Message-ID: <87vbt3m98p.fsf@nemi.mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
	<20140516.224032.2301577488192248796.davem@davemloft.net>
	<87d2fcoqay.fsf@nemi.mork.no> <20140518011917.11270.qmail@stuge.se>
	<alpine.LNX.2.03.1405181155310.7743@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org
To: Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>, Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.03.1405181155310.7743-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Enrico Mioso's
	message of "Sun, 18 May 2014 11:57:05 +0200 (CEST)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I could be wrong, but my impression is that the userspace API
preferences for network devices are

 1. ethtool
 2. sysfs
 3. module param
 ..
 99. ioctl

This is the primary reason why I was looking for someplace to put this
within the existing ethtool API.  Using sysfs would have worked fine
too, I guess.  But is there any real advantage, making it worth a
switch?  I am all open to change to sysfs instead before v3.16 is
released, *if* there are good reasons to do it. And no objections.  But
I do want more of a reason than the fact that it can be done.  Maybe I
got the preferred order wrong?

I ruled out module parameters early because I believe there are real us=
e
cases requiring different settings per device.  The limited host system
resources will of course affect all devices on a single host the same
way.  But not all devices can cope with the reduced buffers. So there
should be some way to tune two devices connected to the same host
differently.

I am not going to say anything about ioctls :-)


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
