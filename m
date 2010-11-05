From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: don't remove address state on ifdown
 if the address is being kept
Date: Fri, 05 Nov 2010 08:12:54 -0700 (PDT)
Message-ID: <20101105.081254.193711384.davem@davemloft.net>
References: <AANLkTimyqFoUvjQM_qLS2YeVmJQ_6-LJc6KfLVE-mzH3@mail.gmail.com>
	<AANLkTimLicmgC3BptZvXGoA0aN6-cFJtRG3DpqJ3NTpJ@mail.gmail.com>
	<AANLkTine2qXg7MTFyh=Ka=tB8fuzB18-NVRryTyc=LKp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maze@google.com, brian.haley@hp.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52292
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751538Ab0KEPMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 11:12:30 -0400
In-Reply-To: <AANLkTine2qXg7MTFyh=Ka=tB8fuzB18-NVRryTyc=LKp@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Fri, 5 Nov 2010 14:45:28 +0800

> On Thu, Oct 28, 2010 at 2:45 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
>>> Fix it so that none of this state is updated if the address is being kept on the interface.
> 
> David, any feedback on this? The existing code clearly has the
> intention of keeping the addresses around, except they don't actually
> work, and this just fixes the bug.

I'm travelling and busy at Kernel Summit and Linux Plumbers Conference,
so I'm only processing the most easiest patches this week.

I'll look into this when I get back.
