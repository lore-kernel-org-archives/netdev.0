From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Tue, 14 Apr 2015 18:30:03 +0200
Message-ID: <20150414163002.GB4309@localhost.localdomain>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>
 <20150328082853.GA4255@localhost.localdomain>
 <5519D380.6070200@cogentembedded.com>
 <552C25BE.3070606@cogentembedded.com>
 <20150414052729.GA5179@netboy>
 <552CE890.3040103@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	masaru.nagai.vx@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:33648 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932797AbbDNQaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 12:30:10 -0400
Content-Disposition: inline
In-Reply-To: <552CE890.3040103@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2015 at 01:14:40PM +0300, Sergei Shtylyov wrote:
> >It is surely avoidable.  The driver knows (or should know) whether or
> >not the hardware has been configured or not.
> 
>    So you only want to avoid the register read here?

No, that is not what I mean.  The two callers are gettime and adjtime.
Can't you make sure the hardware is ready before you register the
clock in the first place?  If not, what is purpose of returning EBUSY?

Thanks,
Richard
