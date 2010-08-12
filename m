From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Thu, 12 Aug 2010 11:39:14 +0900
Message-ID: <004301cb39c7$900912e0$66f8800a@maildom.okisemi.com>
References: <4C61EDE5.4030505@dsn.okisemi.com> <AANLkTinZ510_k2E5JFxa8jcuv8gRABFakyrcfzsg2vm1@mail.gmail.com> <D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB@shsmsx501.ccr.corp.intel.com>
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>, <arjan@linux.intel.com>,
	<gregkh@suse.de>,
	"Khor, Andrew Chih Howe" <andrew.chih.howe.khor@intel.com>,
	<netdev@vger.kernel.org>, <socketcan-core@lists.berlios.de>,
	"Wolfgang Grandegger" <wg@grandegger.com>, <meego-dev@meego.com>
To: "Daniel Baluta" <daniel.baluta@gmail.com>,
	"Wang, Qi" <qi.wang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:11250 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758804Ab0HLCjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 22:39:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Qi-san

> OKI-sans, would you please take a look at ./include/linux/kfifo.h, and try to use this structure and APIs?

Thank you for your answer.
We will start doing the above next week.

Thanks, Ohtake
----- Original Message ----- 
From: "Wang, Qi" <qi.wang@intel.com>
To: "Daniel Baluta" <daniel.baluta@gmail.com>; "Masayuki Ohtak" <masa-korg@dsn.okisemi.com>
Cc: <meego-dev@meego.com>; "Wolfgang Grandegger" <wg@grandegger.com>; <socketcan-core@lists.berlios.de>;
<netdev@vger.kernel.org>; "Khor, Andrew Chih Howe" <andrew.chih.howe.khor@intel.com>; <gregkh@suse.de>;
<arjan@linux.intel.com>; "Wang, Yong Y" <yong.y.wang@intel.com>
Sent: Thursday, August 12, 2010 10:42 AM
Subject: RE: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35


> > -----Original Message-----
> > From: Daniel Baluta [mailto:daniel.baluta@gmail.com]
> > Sent: Wednesday, August 11, 2010 6:37 PM
> > To: Masayuki Ohtak
> > Cc: meego-dev@meego.com; Wolfgang Grandegger;
> > socketcan-core@lists.berlios.de; netdev@vger.kernel.org; Khor, Andrew Chih
> > Howe; gregkh@suse.de; arjan@linux.intel.com; Wang, Qi; Wang, Yong Y
> > Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
> >
> > Hi,
> >
> > 2010/8/11 Masayuki Ohtak <masa-korg@dsn.okisemi.com>:
> > > CAN driver of Topcliff PCH
> > >
> > > Topcliff PCH is the platform controller hub that is going to be used in
> > > Intel's upcoming general embedded platform. All IO peripherals in
> > > Topcliff PCH are actually devices sitting on AMBA bus.
> > > Topcliff PCH has CAN I/F. This driver enables CAN function.
> > >
> > > Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> >
> > I have a few questions:
> >
> > 1. Is your code based on Intel's CAN EP80579 ([1]) ?
> No.
> > 2. Why don't you use kernel existing kfifo infrastructure? ([2]).
> Just take a look at kfifo.h. This structure has been changed. I remembered there was a spin_lock from kfifo
previously. Currently it's been removed, good.
> OKI-sans, would you please take a look at ./include/linux/kfifo.h, and try to use this structure and APIs?
>
> Daniel,
>
> We're anxious to integrate those codes now. Perhaps it'll take us quite a long time to use kfifo. How about
implementing it with the next version?
>
> Best Regards,
> Qi.
>
> > 3. Can you provide a pointer to Topcliff PCH CAN I/F datasheet ?
> Currently this datasheet isn't open.
> >
> > thanks,
> > Daniel.
> >
> > [1] http://www.intel.com/design/intarch/ep80579/sw_tools.htm
> > [2] http://lxr.linux.no/#linux+v2.6.35/kernel/kfifo.c
>


