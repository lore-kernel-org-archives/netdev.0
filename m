From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: double free issue, mvpp2 driver, armada375 modules
Date: Tue, 13 Dec 2016 17:55:18 +0100
Message-ID: <20161213175518.3b3b1ff8@free-electrons.com>
References: <57272206.6070703@corp.ovh.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        marcin wojtas <mw@semihalf.com>, <davem@davemloft.net>,
        =?UTF-8?B?R3LDqWdvcnk=?= Clement
        <gregory.clement@free-electrons.com>
To: Raphael G <raphael.glon@corp.ovh.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:33668 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932900AbcLMQzZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 11:55:25 -0500
In-Reply-To: <57272206.6070703@corp.ovh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, 2 May 2016 11:46:46 +0200, Raphael G wrote:

> enclosed the kernel panic we obtain after boot with a slightly patched 
> upstream kernel (4.5.2).
> 
> (as well as the patchset applied to the upstream kernel, so that you can 
> know which code we are talking about. Too bad we cannot use the upstream 
> kernel but we had no choice about this + we're no experts so we rely on 
> provided patches, adapted to our bootloader and hardware for this)
> 
> Reproduce:
> boot on kernel on an armada375 module, connect to it, launch a top in 
> commandline
> 
> As seen with Marcin Wojtas, reverting commit 
> e864b4c7b184bde36fa6a02bb3190983d2f796f9 fixes this issue.
> 
> Reporting upstream so that you can decide what should be done next

Thanks for your report. I have finally submitted a fix for this issue.
You can find it at:

  http://lists.infradead.org/pipermail/linux-arm-kernel/2016-December/473989.html

If you have the time to test it and report back, it would be very
useful.

Thanks a lot!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
