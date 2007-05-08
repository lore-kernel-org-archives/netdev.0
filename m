From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.3 - QMGR
Date: Tue, 08 May 2007 15:57:37 +0200
Message-ID: <m3odkv76zy.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	<m3hcqoa772.fsf@maximus.localdomain>
	<86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>
	<m33b289zku.fsf@maximus.localdomain>
	<m31whs5ehn.fsf_-_@maximus.localdomain>
	<E209283D-35CB-48E7-A23D-D3CEABEFAAE4@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Michael-Luke Jones <mlj28@cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45839 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934536AbXEHN5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 09:57:38 -0400
In-Reply-To: <E209283D-35CB-48E7-A23D-D3CEABEFAAE4@cam.ac.uk> (Michael-Luke Jones's message of "Tue, 8 May 2007 08:05:02 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael-Luke Jones <mlj28@cam.ac.uk> writes:

> Already in mach-ixp4xx, so can just be called qmgr.c

Same here.

>> +#define QUEUE_IRQ_SRC_NEARLY_FULL	2
>> +#define QUEUE_IRQ_SRC_FULL		3
>> +#define QUEUE_IRQ_SRC_NOT_EMPTY		4
>> +#define QUEUE_IRQ_SRC_NOT_NEARLY_EMPTY	5
>> +#define QUEUE_IRQ_SRC_NOT_NEARLY_FULL	6
>> +#define QUEUE_IRQ_SRC_NOT_FULL		7
>
> Here, unlike ixp4xx_npe.c defines are in qmgr.h - that seems a bit
> more natural.

Because they are public interface :-)
-- 
Krzysztof Halasa
