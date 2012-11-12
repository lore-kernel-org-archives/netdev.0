From: Adrian Chadd <adrian@freebsd.org>
Subject: Re: ath9k_htc-based adapter unfunctioning after commit ceb26a6013
Date: Mon, 12 Nov 2012 13:39:34 -0800
Message-ID: <CAJ-Vmon04wLvn0DDnD9X98bY8DxHRQf10jQJCbuckbztS261vQ@mail.gmail.com>
References: <CA++BO6SuRgOu7A4BKobrdEeSpSc3UUYHXaECmEGE=R17w7HjQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-wireless@vger.kernel.org, jouni@qca.qualcomm.com,
	vthiagar@qca.qualcomm.com, linville@tuxdriver.com,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
	nbd@openwrt.org
To: Corey Richardson <corey@octayn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64781 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888Ab2KLVje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 16:39:34 -0500
In-Reply-To: <CA++BO6SuRgOu7A4BKobrdEeSpSc3UUYHXaECmEGE=R17w7HjQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Please create a bugzilla.kernel.org ticket with this info?

Thanks,



adrian


On 12 November 2012 05:34, Corey Richardson <corey@octayn.net> wrote:
> I was giving 3.7-rc4 a whirl when I discovered my wireless adapter [0] wasn't
> working: the LED didn't light up. Went and ran 'ip link' and it just hung there.
> Tried a few other things and discovered that sudo was broken too. With
> strace I found that they were hanging in sendto().
>
> If I then unplug the adapter, everything comes out of the hang.
>
> Bisected and found that commit ceb26a6013b962b82f644189ea29d802490fc8fc is
> to blame.
>
> Attached is my .config,. The complete dmesg is attached, as well as
> dmesg_disconnect which is what gets spat out on disconnect of the device.
> strace is an strace of 'ip link'.
>
> I feel like I haven't given enough information; anything else needed?
>
> (Please CC me in any reply to a list; I am not subscribed to them)
>
> [0] - http://support.netgear.com/product/WNA1100
>
> --
> Corey Richardson
