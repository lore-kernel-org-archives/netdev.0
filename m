From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Intel wireless microcode problem..
Date: Thu, 14 Aug 2014 10:46:38 -0600
Message-ID: <CA+55aFwhjkhwa+fNE7ZQm_0H0gpjgMNo=C8Cqa6byJUYaq80Jw@mail.gmail.com>
References: <CA+55aFxdt-9e9X0EYCu2Ku8sSTspUGPk5qKa72XH63zrkdPthw@mail.gmail.com>
	<53ECD8D0.4050709@lwfinger.net>
	<CA+55aFw1LWO+zxePYtUBi9YOWHPX+98xbM2h3j4pcN+6V0G1zA@mail.gmail.com>
	<0BA3FCBA62E2DC44AF3030971E174FB31B266E67@hasmsx107.ger.corp.intel.com>
	<CANUX_P2KXKO9UcJbF1TniP64uY6ZJY2SqbKsoEsNqDTT0KFhdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:42653 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbaHNQqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 12:46:39 -0400
In-Reply-To: <CANUX_P2KXKO9UcJbF1TniP64uY6ZJY2SqbKsoEsNqDTT0KFhdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 10:34 AM, Emmanuel Grumbach <egrumbach@gmail.com> wrote:
>
> Ok - I think I have a fix. I could reproduce your problem and I verified my fix.

Yes. The patch didn't apply for me (maybe whitespace damage, maybe you
have other changes there too), but I commented out the
WIPHY_FLAG_SUPPORTS_SCHED_SCAN flag setting, and things seem to work
much better for me now. Of course, maybe I was lucky, but it seemed to
happen pretty much all the time when looking for access points before.

So you can add a tested-by from me if you haven't already committed things.

Thanks,

       Linus
