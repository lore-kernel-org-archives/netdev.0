From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] xen: drop anti-dependency on X86_VISWS
Date: Thu, 07 Apr 2011 10:00:21 -0700
Message-ID: <4D9DEDA5.6020706@zytor.com>
References: <1301828839.2837.143.camel@edumazet-laptop>	 <20110403.172407.91341067.davem@davemloft.net>	 <1301910955.23887.75.camel@zakaz.uk.xensource.com>	 <20110406.144515.235693855.davem@davemloft.net> <1302159483.31620.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"randy.dunlap@oracle.com" <randy.dunlap@oracle.com>,
	"pazke@donpac.ru" <pazke@donpac.ru>,
	"linux-visws-devel@lists.sf.net" <linux-visws-devel@lists.sf.net>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:40113 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756155Ab1DGRBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 13:01:16 -0400
In-Reply-To: <1302159483.31620.36.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2011 11:58 PM, Ian Campbell wrote:
> 
> I'm not sure why ELAN belongs in the EXTENDED_PLATFORM option space
> rather than in the CPU choice option, since its only impact seems to be
> on -march, MODULE_PROC_FAMILY and some cpufreq drivers which doesn't
> sound like an extended platform to me but does it appear to be
> deliberate (see 9e111f3e167a "x86: move ELAN to the
> NON_STANDARD_PLATFORM section", that was the old name for
> EXTENDED_PLATFORM).
> 

Historic... we used to have nonstandard A20M# handling on Elan, until it
was discovered that we could make it work without it.

	-hpa


-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

