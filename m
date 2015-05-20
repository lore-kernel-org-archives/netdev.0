From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] vxlan: correct typo in call to unregister_netdevice_queue
Date: Wed, 20 May 2015 10:12:28 +0200
Message-ID: <555C41EC.6040100@6wind.com>
References: <1431971484-23467-1-git-send-email-linville@tuxdriver.com> <20150518.165941.65628962518379011.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:34112 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbbETIMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 04:12:31 -0400
Received: by wghq2 with SMTP id q2so44091166wgh.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 01:12:30 -0700 (PDT)
In-Reply-To: <20150518.165941.65628962518379011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/05/2015 22:59, David Miller a =E9crit :
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Mon, 18 May 2015 13:51:24 -0400
>
>> By inspection, this appears to be a typo.  The gating comparison
>> involves vxlan->dev rather than dev.  In fact, dev is the iterator i=
n
>> the preceding loop above but it is actually constant in the 2nd loop=
=2E
>>
>> Use of dev seems to be a bad cut-n-paste from the prior call to
>> unregister_netdevice_queue.  Change dev to vxlan->dev, since that is
>> what is actually being checked.
>>
>> Signed-off-by: John W. Linville <linville@tuxdriver.com>
>
> Indeed, your fix looks correct to me.
>
> Applied, thanks John.
>
I was off the last couple of days. But I agree with that patch.
=46WIW:
=46ixes: f01ec1c017de ("vxlan: add x-netns support")
