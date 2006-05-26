From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: Safe remote kernel install howto (Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP (ARCH=ppc))
Date: Fri, 26 May 2006 15:21:53 +0200
Message-ID: <200605261521.53884.netdev@axxeo.de>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org> <200605261429.36078.netdev@axxeo.de> <200605261442.32319.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Meelis Roos <mroos@linux.ee>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:12256 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1750714AbWEZNWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 09:22:04 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200605261442.32319.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andi,

Andi Kleen wrote:
> > 4. Put "sysctl -w kernel.panic_on_oops=1" as early as possible
> >      in your boot scripts[1].
> 
> You can as well boot with oops=panic

Only on x86_64 as of Linux 2.6.16.
But maybe this could be put into kernel/panic.c instead :-)

Regards

Ingo Oeser
