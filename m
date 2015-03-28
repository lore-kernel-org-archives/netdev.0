From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Sat, 28 Mar 2015 09:36:00 +0100
Message-ID: <20150328083600.GB4255@localhost.localdomain>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>
 <55163959.8080101@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:34975 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbbC1IgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 04:36:07 -0400
Content-Disposition: inline
In-Reply-To: <55163959.8080101@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 28, 2015 at 06:17:13AM +0100, Lino Sanfilippo wrote:
> 
> Do you really need one huge lock for all register accesses? Maybe you
> should rethink which registers can actually be accessed concurrently and
> implement some finer grained locking.

One lock is fine, unless the registers are highly contended.

Thanks,
Richard
