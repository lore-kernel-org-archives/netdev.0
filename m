From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Thu, 27 Mar 2008 21:55:45 -0400
Message-ID: <20080328015545.GC4695@codemonkey.org.uk>
References: <20080328000013.GA8193@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:53367 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694AbYC1Bzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 21:55:52 -0400
Received: from c-66-30-206-50.hsd1.ma.comcast.net ([66.30.206.50] helo=gelk.kernelslacker.org)
	by testure.choralone.org with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <davej@gelk.kernelslacker.org>)
	id 1Jf3kq-0004yT-5y
	for netdev@vger.kernel.org; Fri, 28 Mar 2008 01:51:40 +0000
Received: from davej by gelk.kernelslacker.org with local (Exim 4.68)
	(envelope-from <davej@gelk.kernelslacker.org>)
	id 1Jf3on-00058I-NY
	for netdev@vger.kernel.org; Thu, 27 Mar 2008 21:55:45 -0400
Content-Disposition: inline
In-Reply-To: <20080328000013.GA8193@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2008 at 08:00:13PM -0400, Dave Jones wrote:
 > I see this every time I shut down.
 
Something that may be relevant.. There are two NICs in this machine.
An onboard e100, which is in use, and there's a PCI tulip card in there
which doesn't even have a cable plugged into it.

The not-in-use card seems to be the trigger.

	Dave 

-- 
http://www.codemonkey.org.uk
