From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: Repeatable r8169 kernel oops testcase
Date: Sun, 30 Nov 2008 06:38:35 -0600
Message-ID: <20081130063835.43284112@osprey.hogchain.net>
References: <1228040955.3304.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Dale Ogilvie <k1qeelx02@sneakemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:22647 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbYK3Mil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 07:38:41 -0500
Received: by yx-out-2324.google.com with SMTP id 8so785779yxm.1
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2008 04:38:39 -0800 (PST)
In-Reply-To: <1228040955.3304.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Nov 2008 23:29:14 +1300
Dale Ogilvie <k1qeelx02@sneakemail.com> wrote:

> after having some issues with networking on Fedora 10 I was given your
> name to provide some data to. See this fedora forum
> post :http://forums.fedoraforum.org/showthread.php?t=205609

This line from your dmesg caught my eye.

Clocksource tsc unstable (delta = -249993826 ns)

Does booting with clocksource=hpet change anything?  What about the
others in 
/sys/devices/system/clocksource/clocksource0/available_clocksource

Jay
