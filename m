From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH] ehea: Optional TX/RX path optimized for SMP
Date: Mon, 26 Feb 2007 14:43:46 +0100
Message-ID: <200702261443.46791.ossthema@de.ibm.com>
References: <200702231730.58579.ossthema@de.ibm.com> <adairdses3s.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:60463 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030233AbXBZNtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 08:49:55 -0500
In-Reply-To: <adairdses3s.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

> Also, as far as the approach of using tasklets, I think it would be
> better to use the "fake netdev" approach to continue to use NAPI.
> Basically you create a pseudo-netdev for each receive queue and have
> NAPI handle the polling for you -- you could look for
> drivers/net/cxgb3 for an example of this.
> 
Thanks for pointing us to this solution. We are now building a NAPI version
that makes use of these pseudo-netdev. The fairness amongst other netdevices
should be better this way.

> 
> Why make this a module option that the user has to set?  Are there any
> circumstances when someone wouldn't want "significant performance
> improvements?"  If this approach is just better, then it should just
> replace the old code.
> 

We'll change the default behaviour to multi queue, but we'd like to keep
the option to run in a single queue mode for debug and backward compabilty.

Thanks,

Jan-Bernd & Christoph R.
 
