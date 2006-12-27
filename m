From: "Nick Kossifidis" <mickflemm@gmail.com>
Subject: Re: d80211 constants inside d80211_common.h
Date: Wed, 27 Dec 2006 22:58:14 +0200
Message-ID: <40f31dec0612271258w6f1f4503h7a2c1919d6521b66@mail.gmail.com>
References: <40f31dec0612270032g284160a8q2c6f190b4296a455@mail.gmail.com>
	 <200612271107.45572.flamingice@sourmilk.net>
	 <40f31dec0612270926m6447309do7cbf78b28ee904ae@mail.gmail.com>
	 <200612271412.20125.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"David Kimdon" <david.kimdon@devicescape.com>,
	linville@tuxdriver.com, jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:21616 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781AbWL0U6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 15:58:15 -0500
Received: by wx-out-0506.google.com with SMTP id h27so4342499wxd
        for <netdev@vger.kernel.org>; Wed, 27 Dec 2006 12:58:14 -0800 (PST)
To: "Michael Wu" <flamingice@sourmilk.net>
In-Reply-To: <200612271412.20125.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you, i'll use directly IEEE80211_RATE_* ;-)


Nick

2006/12/27, Michael Wu <flamingice@sourmilk.net>:
> On Wednesday 27 December 2006 12:26, Nick Kossifidis wrote:
> > We need those definitions for setting up the rate tables in dadwifi,
> > phytypes are needed inside drivers, take a look here ->
> > http://madwifi.org/browser/branches/dadwifi-openhal/openhal/ar5xxx.h?rev=18
> >67
> >
> MODE_IEEE80211A/B/G and IEEE80211_RATE_* not enough? The definitions in
> d80211_common.h are used for communications with userspace, not drivers. If
> you are using the ieee80211_phytype_* in things that are passed to d80211, it
> is wrong. If you are not, you can switch to MODE_IEEE80211A/B/G and
> IEEE80211_RATE_*, though I think MODE_IEEE80211A/B/G should be all you need.
>
> > Even if it does get out, constants should be in capitals.
> >
> Sure. Submit a patch. :)
>
> -Michael Wu
>
>
>
