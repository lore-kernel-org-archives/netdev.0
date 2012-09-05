From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [V2 PATCH 6/9] csiostor: Chelsio FCoE offload driver submission
 (headers part 1).
Date: Thu, 6 Sep 2012 00:07:17 +0100
Message-ID: <1346886437.5325.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com>
	 <1346848442-4573-7-git-send-email-naresh@chelsio.com>
	 <20120905093133.5f97fcbb@nehalam.linuxnetplumber.net>
	 <50478B36.6000103@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62776 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759854Ab2IEXHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 19:07:21 -0400
In-Reply-To: <50478B36.6000103@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 22:56 +0530, Naresh Kumar Inna wrote:
> On 9/5/2012 10:01 PM, Stephen Hemminger wrote:
> > On Wed,  5 Sep 2012 18:03:59 +0530
> > Naresh Kumar Inna <naresh@chelsio.com> wrote:
> > 
> >> +#define CSIO_ROUNDUP(__v, __r)		(((__v) + (__r) - 1) / (__r))
> > 
> > This is similar to existing round_up() in kernel.h could you use that?
> > 
> I will replace it with round_up() if it serves the same purpose. Thanks.

Stephen is probably thinking of DIV_ROUND_UP().  round_up() does
something different.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
