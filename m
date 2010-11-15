From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next-26 5/5] cxgb4vf: Mark "UDP [RSS Hash] Enable" as a 1-bit field.
Date: Mon, 15 Nov 2010 09:43:32 -0800
Message-ID: <201011150943.32541.leedom@chelsio.com>
References: <1289503844-18059-1-git-send-email-leedom@chelsio.com> <1289503844-18059-6-git-send-email-leedom@chelsio.com> <20101115.092059.59691885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5697 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933386Ab0KORne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 12:43:34 -0500
In-Reply-To: <20101115.092059.59691885.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Miller <davem@davemloft.net>
| Date: Monday, November 15, 2010 09:20 am
| 
| From: Casey Leedom <leedom@chelsio.com>
| Date: Thu, 11 Nov 2010 11:30:44 -0800
| 
| > +		uint synmapen:1;	/* SYN Map Enable */
| 
| Please do not use the "uint" shorthand for "unsigned int", I know it's
| in linux/types.h but that is there for sysv compatibility in
| userspace and is ugly as hell.

  Okay, sorry about that.  I wasn't sure so I looked around and saw several 
other network device drivers using "uint" and figured it was okay.  I assume 
that it's okay to use u32, etc?  I was just trying to be neet and solve the 
"greater than 80 column" restriction which the patch check script complains 
about for when a previous changeset converted "int" to "unsigned int".  Just let 
me know what the correct action is and I'll respin this one patch.  Thanks for 
your patience with my ignorance!

Casey
