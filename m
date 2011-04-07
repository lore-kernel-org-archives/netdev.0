From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] xen: drop anti-dependency on X86_VISWS
Date: Thu, 07 Apr 2011 11:07:38 -0700
Message-ID: <4D9DFD6A.1060200@goop.org>
References: <1301828839.2837.143.camel@edumazet-laptop>	<20110403.172407.91341067.davem@davemloft.net>	<1301910955.23887.75.camel@zakaz.uk.xensource.com>	<20110406.144515.235693855.davem@davemloft.net> <1302159483.31620.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"randy.dunlap@oracle.com" <randy.dunlap@oracle.com>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"linux-visws-devel@lists.sf.net" <linux-visws-devel@lists.sf.net>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"pazke@donpac.ru" <pazke@donpac.ru>,
	"mingo@redhat.com" <mingo@redhat.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claw.goop.org ([74.207.240.146]:37877 "EHLO claw.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755436Ab1DGSHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 14:07:42 -0400
In-Reply-To: <1302159483.31620.36.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2011 11:58 PM, Ian Campbell wrote:
> On Wed, 2011-04-06 at 22:45 +0100, David Miller wrote:
>> From: Ian Campbell <Ian.Campbell@eu.citrix.com>
>> Date: Mon, 4 Apr 2011 10:55:55 +0100
>>
>>> You mean the "!X86_VISWS" I presume? It doesn't make sense to me either.
>> No, I think 32-bit x86 allmodconfig elides XEN because of it's X86_TSC dependency.
> TSC is a real dependency of the Xen interfaces.

Not really.  The TSC register is a requirement, but that's going to be
present on any CPU which can boot Xen.  We don't need any of the
kernel's TSC machinery though.

    J
