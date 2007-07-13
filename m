From: "seventh guardian" <seventhguardian@gmail.com>
Subject: Re: d80211 deadlock with wpa_supplicant and rmmod
Date: Fri, 13 Jul 2007 13:05:43 +0100
Message-ID: <1caff7430707130505r579ef08cmacc6c77f7535a66c@mail.gmail.com>
References: <1caff7430707111617o70a534a5x2cf6b611a91f301a@mail.gmail.com>
	 <20070711234153.GB5099@tuxdriver.com>
	 <1184234538.6669.30.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:24630 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171AbXGMMFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 08:05:45 -0400
Received: by wr-out-0506.google.com with SMTP id i30so314835wra
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2007 05:05:44 -0700 (PDT)
In-Reply-To: <1184234538.6669.30.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/12/07, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Wed, 2007-07-11 at 19:41 -0400, John W. Linville wrote:
>
> > > >I believe we have a deadlock in d80211.
> > >
> > > I have it too. But I'm using iwl3945 driver, in-kernel mac80211, and a
> > > gentoo kernel (basically a patched vanilla-2.6.22.1). My machine is a
> > > x86_64 core 2 duo.
> > >
> > > >The following triggers it on my 2way SMT machine with preempt.
> > > >
> > > >modprobe bcm43xx-d80211
> > > >add sta0
> > > >ifconfig sta0 up
> > > >start wpa_supplicant on the interface
> > > >rmmod bcm43xx-d80211
>
> Sounds like the bug with the scheduled work locking. See the
> "mac80211/bcm43xx deadlock" thread, there's a patch, report back if you
> can/can not reproduce with the patch.

Hello, sorry for the delay but I only managed to try it out today..
I've applied the patch and tortured the system as far as I could, and
no hang at all :)

I've read the thread and it apparently replaces one bad problem for a
lesser one, so I understand if it's not applied.. But at least there
is a place in the code to point as the culprit :)

Thanks,
  Renato Caldas
