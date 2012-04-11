From: Felipe Contreras <felipe.contreras@gmail.com>
Subject: Who should find out the initial frequency of IBSS join?
Date: Wed, 11 Apr 2012 18:53:03 +0300
Message-ID: <CAMP44s2i6dgWrfZTmU04TeiW8e2rh_AERw1PCTPDb7HjeY9ZDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55377 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755761Ab2DKPxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 11:53:05 -0400
Received: by eekc41 with SMTP id c41so272309eek.19
        for <netdev@vger.kernel.org>; Wed, 11 Apr 2012 08:53:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm a total noob at this, but I'm trying to properly fix an issue I'm
having while joining an ad-hoc network with wpa_supplicant; nl80211:
Join IBSS failed. Specifying any frequency makes it work.

Apparently I'm not the only one that has had this issue, however the
fix I found is in NetworkManager[1], but there's a lot of people that
don't use NetworkManager. I tried to file a bug in wpa_supplicant [2],
but they don't think it's a problem there.

Although I think I might be able to write a fix in wpa_supplicant, I
wonder if it might make sense to do it in the nl80211 driver. Wouldn't
it be possible for the driver to check if there's no frequency, and
just try any that is supported?

Cheers.

[1] https://gitorious.org/lanedo/networkmanager/commit/0b5ab39dbf14b4d3d34c4a37b10fa084d0fb272a/diffs
[2] http://w1.fi/bugz/show_bug.cgi?id=439

-- 
Felipe Contreras
