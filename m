From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3: link is permanently down after ifdown and ifup
Date: Thu, 19 Nov 2009 14:50:53 -0800
Message-ID: <1258671053.14964.20.camel@nseg_linux_HP1.broadcom.com>
References: <4B056158.5060104@embedded-sol.com>
 <4B056D85.5010904@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>
To: "Felix Radensky" <felix@embedded-sol.com>, mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1819 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757802AbZKSXAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 18:00:44 -0500
In-Reply-To: <4B056D85.5010904@embedded-sol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2009-11-19 at 08:08 -0800, Felix Radensky wrote:
> Hi,
> 
> The problem goes away if I remove the call to
> 
> tg3_set_power_state(tp, PCI_D3hot);
> 
> from tg3_close().

Added Matt to CC.  He is on vacation and may not be able to look into
this right away.  Thanks.



