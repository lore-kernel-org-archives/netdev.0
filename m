From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 8 Aug 2007 18:30:19 +0200
Message-ID: <200708081830.20129.mb@bu3sch.de>
References: <200708080045.l780jE9E004667@neteffect.com> <200708081555.03588.mb@bu3sch.de> <aday7gmov8o.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, Jeff Garzik <jeff@garzik.org>,
	ggrundstrom@neteffect.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:60991
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964842AbXHHQbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 12:31:17 -0400
In-Reply-To: <aday7gmov8o.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 August 2007 18:18:31 Roland Dreier wrote:
>  > But there are indeed a few cases that look wrong.
> 
> yes...
> 
>  > arch/x86_64/kernel/pci-calgary.c:       writel(cpu_to_be32(val), target);
> 
> eg this almost certainly wants to be
> 
> 	writel(swab32(val), target);
> 
> or something equivalent like
> 
> 	__raw_writel(cpu_to_be32(val), target);
> 	/* plus some suffficent memory ordering */
> 
>  - R.
> 
> 

certainly, yes.
Most likely the __raw_writel variant is portable, but I am not
sure. Anybody sure?

-- 
Greetings Michael.
