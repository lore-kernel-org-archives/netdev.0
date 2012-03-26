From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
 timecompare method
Date: Mon, 26 Mar 2012 11:07:40 -0400
Message-ID: <CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
References: <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
	<20120316065537.GB2199@netboy.at.omicron.at>
	<CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
	<20120321170003.GA5533@netboy.at.omicron.at>
	<02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
	<20120322064107.GB2182@netboy.at.omicron.at>
	<CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
	<20120324065147.GB2201@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59966 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519Ab2CZPHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 11:07:40 -0400
Received: by pbcun15 with SMTP id un15so6087392pbc.19
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 08:07:40 -0700 (PDT)
In-Reply-To: <20120324065147.GB2201@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 24, 2012 at 2:51 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Fri, Mar 23, 2012 at 03:39:08PM -0400, chetan loke wrote:
>>
>> So, how is it working today? Because we could have tx and rx
>> completions on different CPUs. Is it not possible to have the
>> following race today - between timecompare_update->timecompare_offset
>> -> timecounter_readdelta of say Rx and timecounter_cyc2time from Tx?
>
> I works (in the igb) because of the spinlock. You know, that thing
> that you are so against using.
>

I meant, was there a lock before the PHC functionality in igb?

>
>> How about rate limiting at the PHC class driver level? And then it
>> will work across the board for all the adapters at the device level.
>
> No, don't go there. Enough bikeshedding already. If you have a serious

can a user without root privileges use get/adj/set time ioctls for the
PHC functionality?


> Thanks,
> Richard

Chetan
