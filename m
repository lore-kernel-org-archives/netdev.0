From: "m. allan noah" <kitno455@gmail.com>
Subject: Re: forcedeth kernel panic with nForce 630a on 100Mbps FD network
Date: Fri, 29 Feb 2008 10:45:05 -0500
Message-ID: <97246d0e0802290745s38a8b9f5j82deeb49fd97c72e@mail.gmail.com>
References: <97246d0e0802281239t43d9167dwe2740ed11d1300e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:39930 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946AbYB2PpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 10:45:05 -0500
Received: by wf-out-1314.google.com with SMTP id 28so4084300wff.4
        for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 07:45:05 -0800 (PST)
In-Reply-To: <97246d0e0802281239t43d9167dwe2740ed11d1300e0@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 28, 2008 at 3:39 PM, m. allan noah <kitno455@gmail.com> wrote:
> Have two Asus M2N-VN DVI motherboards, Athlon 64 X2 5000+, 8 gigs of
>  ram, both running Fedora 8. with updated distro kernel
>  (2.6.23.15-137).
>
>  When RXing large amounts of data on a 100Meg network, i start seeing
>  RX errors almost immediately, seemingly always equal numbers of
>  rx_frame_error and rx_frame_align_error (according to ethtool -S).
>
>  Soon afterwards, the network speed drops pretty drastically, and then
>  stops altogether. no ping, etc. rmmod and insmod forcedeth seems to
>  fix things again, but if i let the scp continue against the dead card,
>  it will eventually kernel panic.
>
>  there is nothing unusual in syslog, and none of this happens if i
>  connect the two machines directly with crossover cable at 1000Meg
>
>  I have just upgraded one of the machines to vanilla 2.6.24, and i
>  still see the ethtool errors, and eventually the slow downs, but no
>  network freeze or kernel panic yet, so it looks a little better?
>
>  The machines are not going into production for a few weeks, so i
>  wondered if there was any use in getting you guys some debugging info,
>  or any hope of an updated driver to try?
>

Oh, after a few minutes of waiting, 2.6.24 kernel panics too, and
2.6.25-rc3 will temporarily halt the card, but seems to recover some
time later, have not made that kernel panic yet.

if the forcedeth driver devels would like some more info, please
contact me directly.

allan
-- 
"The truth is an offense, but not a sin"
