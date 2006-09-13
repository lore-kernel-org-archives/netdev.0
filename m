From: Daniel Drake <dsd@gentoo.org>
Subject: Re: ieee80211 and devices which decrypt in hardware
Date: Wed, 13 Sep 2006 18:43:44 -0400
Message-ID: <450889A0.1050100@gentoo.org>
References: <45077241.1070102@gentoo.org> <200609131627.58153.mb@bu3sch.de> <450887B9.7080308@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	yi.zhu@intel.com, ipw2100-admin@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp131.iad.emailsrvr.com ([207.97.245.131]:4314 "EHLO
	smtp131.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1751235AbWIMWor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 18:44:47 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <450887B9.7080308@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> adding IEEE802.11 header parsing code to 
> zd1211rw rx path (currently there is none, which is nice)

Oops, that's obviously a lie. Anyway, I still think it's easier/better 
to do in the stack, would you agree? That just leaves questions about 
whether it should be a new flag, special value for ieee->host_decrypt, etc.

Daniel
