From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 09:40:57 -0400
Message-ID: <482D8EE9.10404@garzik.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <20080516132107.GA11304@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58652 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755736AbYEPNlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 09:41:10 -0400
In-Reply-To: <20080516132107.GA11304@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennart Sorensen wrote:
> On Thu, May 15, 2008 at 03:21:49PM -0400, Jeff Garzik wrote:
>> "no other form of entropy"?   See examples in this thread.
> 
> So where does one get entropy if not the ethernet adapter on many
> embedded systems?  If you have no mouse, no keyboard, no hardware number
> generator, just ethernet ports and a serial console that usually
> receives no input.  While ethernet might not be preferable if you have
> something else, sometimes you really don't have anything else.

Already answered in this thread...  EGD illustrates how many sources of 
entropy remain, even in the example you just gave.

Further, you do not want to rely on entropy from a source that declines 
just as network traffic increases.

	Jeff



