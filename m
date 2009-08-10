From: ext Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [Resent][PATCH 1/2] inet6: Conversion from u8 to int
Date: Mon, 10 Aug 2009 09:08:00 +0200
Message-ID: <20090810070800.GA6447@gerrit.erg.abdn.ac.uk>
References: <1249841569-23706-1-git-send-email-gerrit@erg.abdn.ac.uk> <1249841569-23706-2-git-send-email-gerrit@erg.abdn.ac.uk> <200908100933.11676.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: R?mi Denis-Courmont <remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:41409 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751897AbZHJHIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2009 03:08:10 -0400
Content-Disposition: inline
In-Reply-To: <200908100933.11676.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting R?mi Denis-Courmont:
| On Sunday 09 August 2009 21:12:48 ext Gerrit Renker wrote:
| >  	case IPV6_TCLASS:
| >  		val = np->tclass;
| > -		if (val < 0)
| > -			val = 0;
| >  		break;
| 
| According to the IPv6 API RFC, if val is -1, the kernel shall pick the default 
| value (which is zero). Are you sure this still works??
Yes exactly that is the point, but it does not work since np->tclass is __u8, i.e.
val will not be negative here.

What you refer to is done in the second patch and in the combination I think it
will work, please have a look.
