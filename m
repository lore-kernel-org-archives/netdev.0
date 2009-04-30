From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [RFC] Add clause 45 ioctl
Date: Thu, 30 Apr 2009 18:05:59 +0300
Message-ID: <1241103959.10391.3.camel@lb-tlvb-eliezer>
References: <1240913334.8347.6.camel@lb-tlvb-eliezer>
 <1240924931.3200.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2244 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761813AbZD3PJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 11:09:01 -0400
In-Reply-To: <1240924931.3200.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-04-28 at 06:22 -0700, Ben Hutchings wrote:
> > I'm sending this as RFC - if anyone has alternative suggestions on how
> > user space application can access the PHY, I would appreciate it.
> [...]
> 
> I was working on an alternate interface that would use the existing
> structure and ioctls.  There are at least two drivers (cxgb3 and sfc)
> that already do this, though they currently pack PRTAD and DEVAD
> differently in the phy_id field.

I can use the same approach and overload the CL22 definitions, but don't
you think it is cleaner to add the CL45 definition? I think that the
fact that two drivers are already overloading the CL22 for CL45 usage is
showing that CL45 is needed, and the fact that they are doing that
differently shows that there is a need for a clean definition. I'm just
thinking about someone trying to write an application for all CL45
supporting drivers - it is easier if there is a clean interface.

What do you say?

Thanks,
Eilon


