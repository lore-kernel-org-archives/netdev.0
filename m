From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: rocker: Change netdev names to include slot number
Date: Mon, 2 Feb 2015 13:33:08 -0800
Message-ID: <CAE4R7bA0Ea9zugm=OR0EN2qSeoiROEoMiYZ-5YMwd9UdS4L0Sg@mail.gmail.com>
References: <1422856985-16530-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:39734 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161AbbBBVdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 16:33:18 -0500
Received: by mail-we0-f169.google.com with SMTP id u56so41565083wes.0
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 13:33:17 -0800 (PST)
In-Reply-To: <1422856985-16530-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 1, 2015 at 10:03 PM, David Ahern <dsahern@gmail.com> wrote:
> Currently, rocker devices are given eth%d names. If you have multiple
> rocker devices it is difficult to easily correlate eth%d names to a
> rocker device and port. Change the device name to sw + PCI slot
> number + p + id (sw%dp%d). This makes the device names easier to
> correlate. ie., Rather than eth0, ..., eth N (N = number of ports in
> device) the ports get netdev names like sw5p0, ..., sw5pN.

I think udev is the preferred tool for interface naming, rather than
hard-coding interface names in the driver.
