From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rocker: Change netdev names to include slot number
Date: Mon, 02 Feb 2015 14:15:24 -0800 (PST)
Message-ID: <20150202.141524.1261025621046834526.davem@davemloft.net>
References: <1422856985-16530-1-git-send-email-dsahern@gmail.com>
	<CAE4R7bA0Ea9zugm=OR0EN2qSeoiROEoMiYZ-5YMwd9UdS4L0Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545AbbBBWP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 17:15:27 -0500
In-Reply-To: <CAE4R7bA0Ea9zugm=OR0EN2qSeoiROEoMiYZ-5YMwd9UdS4L0Sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Mon, 2 Feb 2015 13:33:08 -0800

> On Sun, Feb 1, 2015 at 10:03 PM, David Ahern <dsahern@gmail.com> wrote:
>> Currently, rocker devices are given eth%d names. If you have multiple
>> rocker devices it is difficult to easily correlate eth%d names to a
>> rocker device and port. Change the device name to sw + PCI slot
>> number + p + id (sw%dp%d). This makes the device names easier to
>> correlate. ie., Rather than eth0, ..., eth N (N = number of ports in
>> device) the ports get netdev names like sw5p0, ..., sw5pN.
> 
> I think udev is the preferred tool for interface naming, rather than
> hard-coding interface names in the driver.

That's correct.
