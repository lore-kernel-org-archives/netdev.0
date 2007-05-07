From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Mon, 07 May 2007 16:31:48 -0400
Message-ID: <463F8CB4.3040603@garzik.org>
References: <m3abwhcy74.fsf@maximus.localdomain>	 <Pine.LNX.4.64.0705070343330.2733@scrub.home>	 <m3tzupc6wz.fsf@maximus.localdomain>	 <Pine.LNX.4.64.0705071318150.1479@scrub.home>	 <m3r6psc0ee.fsf@maximus.localdomain>	 <Pine.LNX.4.64.0705071509290.1479@scrub.home>	 <463F27CE.2040008@garzik.org>	 <Pine.LNX.4.64.0705071538060.1479@scrub.home>	 <m3lkg0a88y.fsf@maximus.localdomain>	 <Pine.LNX.4.64.0705071901020.1479@scrub.home> <a781481a0705071115v5bce9382q166b9c0e0c52c6ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roman Zippel <zippel@linux-m68k.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49653 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966547AbXEGUb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 16:31:58 -0400
In-Reply-To: <a781481a0705071115v5bce9382q166b9c0e0c52c6ef@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:
> Yes, mixing select and depends is a recipe for build disasters. Call
> me a rabid fanatic, but I would in fact go as far as to say that this
> whole "select" thing in the Kconfig process is one big BUG, and not a
> feature. People are lazy by nature and would rather just "select" a
> dependency for their config option than burden users with several
> "depends".

Tough, the kernel community has voted against you.

It makes far more sense to include a driver during kernel configuration, 
and have that driver pull in its libraries via 'select'.  The lame 
alternative requires developers to know which libraries they need BEFORE 
picking their drivers, which is backwards and requires legwork on the 
part of the kernel developer.

	Jeff


