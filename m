From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - NPE
Date: Tue, 08 May 2007 15:56:20 +0200
Message-ID: <m3sla77723.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	<m3hcqoa772.fsf@maximus.localdomain>
	<86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>
	<m33b289zku.fsf@maximus.localdomain>
	<m33b285exl.fsf_-_@maximus.localdomain>
	<8CA5FD65-BEE1-4769-B1DF-81CA82210F61@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Michael-Luke Jones <mlj28@cam.ac.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S968050AbXEHN42@vger.kernel.org>
In-Reply-To: <8CA5FD65-BEE1-4769-B1DF-81CA82210F61@cam.ac.uk> (Michael-Luke Jones's message of "Tue, 8 May 2007 08:02:15 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael-Luke Jones <mlj28@cam.ac.uk> writes:

> Already in mach-ixp4xx, so can just be called npe.c

I want ixp4xx_ prefix in module name, otherwise I'd call it npe.c,
sure.

> Debugging code? Can this go?

Why? Especially with code having to work with third party binary-only
firmware? Suicide. They are eliminated at build time = performance
hit (OTOH this file isn't on any fast path).

> It may be a matter of taste, but could some of the many definitions
> at the top of ixp4xx_npe.c go in the header file here?

It's actually not only a matter of taste, they are private
to the .c file and I don't want to make them available to the
public (but sure, I don't like them in .c either, I think nobody
likes such definitions anywhere but they have to exist somewhere).
-- 
Krzysztof Halasa
