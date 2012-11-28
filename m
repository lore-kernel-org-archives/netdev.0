From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Wed, 28 Nov 2012 17:16:03 +0000
Message-ID: <CAKh2mn6Chv8wJkMPm6G4xzRa0+29-A1BsnbZfia0ALxuthOjcw@mail.gmail.com>
References: <87y5hm9ap5.fsf@nemi.mork.no>
	<Pine.LNX.4.44L0.1211271443150.1489-100000@iolanthe.rowland.org>
	<CAKh2mn7+0itrJNxmh6Wv9njGaNOY48N_zfJm6=gTeMoF2VzW4g@mail.gmail.com>
	<874nka3wgx.fsf@nemi.mork.no>
	<CAKh2mn5UGRN5U0w_bj25e4VnCwr9kK3f798nHSwmF4WE4dORMw@mail.gmail.com>
	<87k3t62btw.fsf@nemi.mork.no>
	<CAKh2mn7VsNYMO-qYyyqR==A2sXjkZo6QXj_kOuem4o1Vu-LLmw@mail.gmail.com>
	<87wqx528ci.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alan Stern <stern@rowland.harvard.edu>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:56629 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254Ab2K1RQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 12:16:06 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so5352384eaa.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 09:16:03 -0800 (PST)
In-Reply-To: <87wqx528ci.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +
>> + ret = device_set_wakeup_enable(&net->dev, pdata->wolopts);
>
> You are touching the network device here.  That should have been the USB
> device.  Try something like
>
>  ret = device_set_wakeup_enable(&dev->udev->dev, pdata->wolopts);

Perfect, this works exactly as expected now.  Patch included in
resubmitted patchset, thanks Bjorn!
