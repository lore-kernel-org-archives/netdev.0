From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] Add clause 45 ioctl
Date: Tue, 28 Apr 2009 14:22:11 +0100
Message-ID: <1240924931.3200.3.camel@achroite>
References: <1240913334.8347.6.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	yanivr@broadcom.com
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:39033 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753243AbZD1NWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 09:22:23 -0400
In-Reply-To: <1240913334.8347.6.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-04-28 at 13:08 +0300, Eilon Greenstein wrote:
> Hi,
> 
> This patch adds clause 45 definitions to the mii.h. This will allow
> enhancing the networking device drivers ioctl to handle clause 45
> related operations just as it can handle clause 22 commands today. Since
> clause 45 requires additional 16 bits for the bank address,

No, DEVAD is only 5 bits.

> the clause
> 22 structure cannot be used. The motivation is to allow user space
> applications to access PHY registers in clause 45.
> 
> I'm sending this as RFC - if anyone has alternative suggestions on how
> user space application can access the PHY, I would appreciate it.
[...]

I was working on an alternate interface that would use the existing
structure and ioctls.  There are at least two drivers (cxgb3 and sfc)
that already do this, though they currently pack PRTAD and DEVAD
differently in the phy_id field.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

