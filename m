From: Rod Whitby <rod@whitby.id.au>
Subject: Why run ixp4xx LE? (Was: [PATCH] Intel IXP4xx network drivers v.2
 - Ethernet and HSS)
Date: Wed, 09 May 2007 14:50:38 +0930
Message-ID: <46415A26.6080209@whitby.id.au>
References: <464034CF.20700@wpkg.org>	<f19298770705080148u70638ac2ue87241382681088@mail.gmail.com> <FCBED7DF-2A16-419A-865D-663C34437579@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tomasz Chmielewski <mangoo@wpkg.org>,
	linux-kernel@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Michael-Luke Jones <mlj28@cam.ac.uk>,
	Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:49081 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754909AbXEIFWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 01:22:18 -0400
In-Reply-To: <FCBED7DF-2A16-419A-865D-663C34437579@cam.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael-Luke Jones wrote:
> On 8 May 2007, at 09:48, Alexey Zaytsev wrote:
> 
>> I was always curious, why do people want to run ixp4xx in LE mode? What
>> are the benefits that overweight the obvious performance degradation?
> 
> Debian.
> http://www.debian.org/ports/arm/

And also out-of-kernel drivers for things like webcams, which have been
naively written for x86 little endian and have no concept of endian
neutrality.  In some cases it's just easier to run LE instead of
fighting with the driver code.

BTW, for the consumer-level IXP42x devices (like the NSLU2) the
performance difference is *completely* overwhelmed by slowness in the
rest of the system.

-- Rod
