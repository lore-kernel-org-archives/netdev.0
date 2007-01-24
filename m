From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: dscape doesn't auto associate
Date: Tue, 23 Jan 2007 20:48:00 -0500
Message-ID: <9e4733910701231748ve5817d1md0710c9d08934a0f@mail.gmail.com>
References: <9e4733910701231523w1de82215g6a142ed1e691674b@mail.gmail.com>
	 <200701231843.05902.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:39588 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933162AbXAXBsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 20:48:02 -0500
Received: by py-out-1112.google.com with SMTP id a29so17427pyi
        for <netdev@vger.kernel.org>; Tue, 23 Jan 2007 17:48:02 -0800 (PST)
To: "Michael Wu" <flamingice@sourmilk.net>
In-Reply-To: <200701231843.05902.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/23/07, Michael Wu <flamingice@sourmilk.net> wrote:
> On Tuesday 23 January 2007 18:23, Jon Smirl wrote:
> > I have to manually associate the dscape stack with my AP. Is this way
> > the code is supposed to work? Everything works ok after the manual
> > association.
> >
> It's suppose to work with wpa_supplicant which sets every parameter.
> NetworkManager uses wpa_supplicant so configuration can be pretty easy.

Something isn't working right with NetworkManager for me. I have both
zd1211 and rt2570 devices and neither will start automatically but I
can get the going manually.

I'll try running NetworkManager in the debugger and see if I can
figure out what is failing. NetworkManager is working ok for me on
non-dscape devices.

As for running as an AP:
rt2570 will start in Master mode
zd1211 refused to set Master mode

zd1211 has this problem too:
Error for wireless request "Set Encode" (8B2A) :
    SET failed on device wlan1 ; Invalid argument.

> If you really want to manually associate, set the channel, (e)ssid, and
> encryption (if any) in any order, and then set the bssid (ap) last. There
> will be patches to allow association by just setting the SSID for backwards
> compatibility with configuration scripts.
>
> -Michael Wu
>
>
>


-- 
Jon Smirl
jonsmirl@gmail.com
