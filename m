From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netconsole fun
Date: Tue, 30 Apr 2013 10:44:21 +0800
Message-ID: <CAM_iQpUyymRjfuWDUhbADHs7XeunAEy4RfzCADS9W+PHFwZN2w@mail.gmail.com>
References: <20121213123611.GA12269@hmsreliant.think-freely.org>
	<1355410171.2605.17.camel@thor>
	<20121213180815.GA14796@hmsreliant.think-freely.org>
	<1355426821.2612.16.camel@thor>
	<20121213211754.GC14796@hmsreliant.think-freely.org>
	<1355437480.2612.33.camel@thor>
	<20121214142018.GA24846@shamino.rdu.redhat.com>
	<1355580838.2467.39.camel@thor>
	<20121217142030.GB25322@hmsreliant.think-freely.org>
	<1367256525.3494.10.camel@thor.lan>
	<20130429182156.GB27119@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f174.google.com ([209.85.128.174]:63001 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755889Ab3D3CoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 22:44:23 -0400
Received: by mail-ve0-f174.google.com with SMTP id b10so35113vea.5
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 19:44:22 -0700 (PDT)
In-Reply-To: <20130429182156.GB27119@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 2:21 AM, Neil Horman <nhorman@tuxdriver.com> wrote:
> I've not tried specifically what want to do, no, but I've done interface
> renaming plenty of times in the initramfs back when I did kdump work (we had to
> rename devices in the initramfs to align them with whatever udev renamed them to
> once we pivot_root-ed to the rootfs).
>

The new kdump infrastructure which uses dracut already switches to udev
completely, it has some rule file to map mac address to its name.
