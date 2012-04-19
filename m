From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: [net-next 1/4 (V3)] net: ethtool: add the EEE support
Date: Thu, 19 Apr 2012 16:48:54 +0300
Message-ID: <4F9017C6.8070400@broadcom.com>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
 <1333704559-11251-2-git-send-email-peppe.cavallaro@st.com>
 <1334269598.2497.50.camel@bwh-desktop.uk.solarflarecom.com>
 <4F8BB103.7020107@st.com> <4F900C08.5000906@st.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4766 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755376Ab2DSNwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 09:52:24 -0400
In-Reply-To: <4F900C08.5000906@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,

> The "set" will be useful for some eth devices (like the stmmac) that can
> stop/enable internally the eee capability (at mac level).

If you're already implementing this interface, don't you think it might be
prudent to create an implementation that can do more than enable/disable
the interface?
I think users would like a method for configuring some of the EEE's variables,
mainly controlling the timers affecting the generation of an LPI request,
as such control might have a direct consequence on the effectiveness of their
energy savings (less time for generation ==> better energy savings, with a
possible latency penalty).

Thanks,
Yuval
