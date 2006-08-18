From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Reasons behind HAVE_TX_TIMEOUT
Date: Fri, 18 Aug 2006 07:31:54 -0400
Message-ID: <44E5A52A.3020209@garzik.org>
References: <44E59CAC.9010300@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37848 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964875AbWHRLb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 07:31:57 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <44E59CAC.9010300@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> Hi,
> 
> Just curious, why do we have an unconditional #define in netdevice.h for 
> HAVE_TX_TIMEOUT, and some drivers (e.g. xirc2ps_cs) using it 
> conditionally as if it might be disabled on some builds?
> 
> There are other similar defines in netdevice.h too.

Ancient back-compat defines, for 2.2-era, pre-softnet code where 
tx_timeout did not exist.

	Jeff


