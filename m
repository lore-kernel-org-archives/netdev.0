From: David Miller <davem@davemloft.net>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Wed, 31 May 2006 23:18:39 -0700 (PDT)
Message-ID: <20060531.231839.10909081.davem@davemloft.net>
References: <20060531130615.GA32362@2ka.mipt.ru>
	<20060531122955.B10147@openss7.org>
	<20060601061234.GB28087@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: draghuram@rocketmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bidulock@openss7.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20151
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751810AbWFAGSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 02:18:07 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060601061234.GB28087@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 1 Jun 2006 10:12:36 +0400

> I've present the new simple code and test results which show
> that folded and not folded Jenkins hashes _do_ produce _exactly_ the
> same distribution.

Ok I believe you now :)

> I think I've already said that fairly distributed values being xored
> produce still fairly distributed value, so parts of 32bit fairly
> distributed hash after being xored with each other still produce fairly
> distributed 32bit space.

It would make a good research paper for someone mathmatically
inclined enough :)
