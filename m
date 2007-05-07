From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 1/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Mon, 7 May 2007 13:50:52 -0700
Message-ID: <20070507135052.cc7e74ca.randy.dunlap@oracle.com>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705070343330.2733@scrub.home>
	<m3tzupc6wz.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071318150.1479@scrub.home>
	<m3r6psc0ee.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071509290.1479@scrub.home>
	<463F27CE.2040008@garzik.org>
	<Pine.LNX.4.64.0705071538060.1479@scrub.home>
	<m3lkg0a88y.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071901020.1479@scrub.home>
	<a781481a0705071115v5bce9382q166b9c0e0c52c6ef@mail.gmail.com>
	<463F8CB4.3040603@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Satyam Sharma <satyam.sharma@gmail.com>,
	Roman Zippel <zippel@linux-m68k.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966821AbXEGUtB@vger.kernel.org>
In-Reply-To: <463F8CB4.3040603@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 07 May 2007 16:31:48 -0400 Jeff Garzik wrote:

> Satyam Sharma wrote:
> > Yes, mixing select and depends is a recipe for build disasters. Call
> > me a rabid fanatic, but I would in fact go as far as to say that this
> > whole "select" thing in the Kconfig process is one big BUG, and not a
> > feature. People are lazy by nature and would rather just "select" a
> > dependency for their config option than burden users with several
> > "depends".
> 
> Tough, the kernel community has voted against you.

Andrew (usually) implores people not to use "select" and I agree
with him.

> It makes far more sense to include a driver during kernel configuration, 
> and have that driver pull in its libraries via 'select'.  The lame 
> alternative requires developers to know which libraries they need BEFORE 
> picking their drivers, which is backwards and requires legwork on the 
> part of the kernel developer.

Developers?  If you had said "users," I might agree, but IMO it's
OK (or even Good) for developers to know what libraries their code
uses/requires.  Yes, that's a good thing.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
