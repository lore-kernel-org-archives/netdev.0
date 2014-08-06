From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [Regression] FEC: Panic on suspend in 3.16
Date: Wed, 6 Aug 2014 13:01:28 -0300
Message-ID: <CAOMZO5ASEsy0NUus3w13zkhq2FsF9x6X5Ce28dXqZFAbQ0E6uA@mail.gmail.com>
References: <53E24147.4050304@parkeon.com>
	<53E24525.2020809@mentor.com>
	<53E24A99.2020604@denx.de>
	<20140806154711.GQ30282@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stefano Babic <sbabic@denx.de>,
	Nathan Lynch <Nathan_Lynch@mentor.com>,
	Martin Fuzzey <mfuzzey@parkeon.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:42402 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbaHFQBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 12:01:30 -0400
Received: by mail-la0-f42.google.com with SMTP id pv20so2319108lab.29
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 09:01:29 -0700 (PDT)
In-Reply-To: <20140806154711.GQ30282@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 6, 2014 at 12:47 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:

> As Nathan says, the problem is caused by a71e3c37960c and the fix which
> will soon be merged into mainline and stable trees will be a revert of
> that commit.

Yes, Dave has already queued the revert for stable:
https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=ce7991e8198b80eb6b4441b6f6114bea4a665d66
