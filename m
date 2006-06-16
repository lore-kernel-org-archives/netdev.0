From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Fri, 16 Jun 2006 03:32:56 -0400
Message-ID: <44925EA8.5070906@pobox.com>
References: <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <448F5952.1060201@pobox.com> <20060614044412.GA30552@colo.lackof.org> <44902554.7010703@pobox.com> <20060614181419.GA10365@colo.lackof.org> <20060614204720.GA17887@electric-eye.fr.zoreil.com> <20060614223021.GB13212@colo.lackof.org> <20060615203017.GA6724@electric-eye.fr.zoreil.com> <20060616054711.GA28524@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:419 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751124AbWFPHdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2006 03:33:05 -0400
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20060616054711.GA28524@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Grundler wrote:
> On Thu, Jun 15, 2006 at 10:30:17PM +0200, Francois Romieu wrote:
>> Afaik free_irq() on a shared irq does not touch the hardware and
>> irqs are anything but synchronous. If free_irq() is issued before
>> the device is idle and its irq are not acked, it's wrong.
> 
> Correct. Before calling free_irq(), patch V3 masks interrupts on tulip
> and guarantees the tulip will not generate new interrupts before that call.

Incorrect -- it does not guarantee that tulip will not generate new 
interrupt events.

	Jeff



