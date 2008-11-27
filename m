From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 0 of 2] implement tty driver for netconsole
Date: Thu, 27 Nov 2008 17:09:45 -0600
Message-ID: <1227827385.3196.49.camel@calx>
References: <patchbomb.1227820260@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hollis Blanchard <hollisb@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:41757 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbYK0XJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 18:09:56 -0500
In-Reply-To: <patchbomb.1227820260@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-27 at 15:11 -0600, Hollis Blanchard wrote:
> I have a Kuro Box (a small NAS device running Linux), and it has no serial
> console (nor any other console for that matter). The most convenient way to get
> boot output is via the netconsole driver, which is what most Kuro owners do. (The u-boot
> firmware even supports interactive netconsole allowing us to edit boot configuration.)
> 
> However, once past kernel boot, userspace currently has no way of outputting data over
> netconsole. These patches enable that, which is really useful for seeing init
> script output and debugging ramdisks before they've brought up sshd.

Awesome! I've been meaning to wire this up for ages. I'll try to look at
it over the weekend.

-- 
Mathematics is the supreme nostalgia of our time.

