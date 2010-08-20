From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Fri, 20 Aug 2010 17:37:41 +0900
Message-ID: <000401cb4042$f5ea66f0$66f8800a@maildom.okisemi.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<AANLkTinZ510_k2E5JFxa8jcuv8gRABFakyrcfzsg2vm1@mail.gmail.com>	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB@shsmsx501.ccr.corp.intel.com>	<4C63B8F8.6090106@grandegger.com> <D5AB6E638E5A3E4B8F4406B113A5A19A28EA2AB1@shsmsx501.ccr.corp.intel.com> <4C65255F.4010709@grandegger.com> <000f01cb402d$34b675b0$66f8800a@maildom.okisemi.com> <4C6E35D5.2080500@grandegger.com>
Cc: "Wang, Qi" <qi.wang@intel.com>, <arjan@linux.intel.com>,
	<meego-dev@meego.com>, "Wang, Yong Y" <yong.y.wang@intel.com>,
	<gregkh@suse.de>, <netdev@vger.kernel.org>,
	<socketcan-core@lists.berlios.de>,
	"Khor, Andrew Chih Howe" <andrew.chih.howe.khor@intel.com>,
	"Morinaga" <morinaga526@dsn.okisemi.com>
To: "Wolfgang Grandegger" <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:18040 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751202Ab0HTIhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 04:37:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wolfgang,

Thank you for your comment.
We don't use kfifo infrastructure but brush up with current framework.

Thanks, Ohtake(OKISEMI)
----- Original Message ----- 
From: "Wolfgang Grandegger" <wg@grandegger.com>
To: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Cc: "Wang, Qi" <qi.wang@intel.com>; <arjan@linux.intel.com>; <meego-dev@meego.com>; "Wang, Yong Y"
<yong.y.wang@intel.com>; <gregkh@suse.de>; <netdev@vger.kernel.org>; <socketcan-core@lists.berlios.de>; "Khor, Andrew
Chih Howe" <andrew.chih.howe.khor@intel.com>; "Morinaga" <morinaga526@dsn.okisemi.com>
Sent: Friday, August 20, 2010 4:59 PM
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35


> Hi Ohtake,
>
> On 08/20/2010 08:01 AM, Masayuki Ohtake wrote:
> > Hi Wolfgang,
> >
> >>>>>> 2. Why don't you use kernel existing kfifo infrastructure? ([2]).
> >>>>> Just take a look at kfifo.h. This structure has been changed. I remembered
> >>>> there was a spin_lock from kfifo previously. Currently it's been removed, good.
> >>>>> OKI-sans, would you please take a look at ./include/linux/kfifo.h, and try to
> >>>> use this structure and APIs?
> >>>>
> >>>> As I see it, the code related to that fifo is not used (== dead code)?
> >>> I'm not familiar with kfifo structure, and I didn't like it because there need a spin_lock to use it.
> >
> > We are about to study kfifo infra structure.
> > I have a question.
> >
> > It seems all CAN drivers accepted by upstream don't use kfifo infrastructure, right ?
>
> Right!
>
> > (I couldn't see message with "grep kfifo * in drivers/net/can")
> >
> > If yes, why should we use the kfifo ?
> > If no, please show me the kfifo reference driver
>
> Sorry, nobody (of the socketcan core developers) said that kfifo should
> be used. We believe, that an additional queuing of CAN messages is *not*
> needed at all. Just eliminate the related code and follow more closely
> the existing mainline drivers.
>
> Wolfgang.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


