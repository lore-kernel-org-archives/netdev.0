From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Thu, 05 Oct 2006 14:04:31 -0700 (PDT)
Message-ID: <20061005.140431.75431182.davem@davemloft.net>
References: <Pine.LNX.4.64.0610021020390.9909@d.namei>
	<20061003.161807.18306641.davem@davemloft.net>
	<Pine.LNX.4.64.0610051657270.25705@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, sds@tycho.nsa.gov,
	vyekkirala@TrustedCS.com, paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63402
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751343AbWJEVEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 17:04:30 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0610051657270.25705@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 5 Oct 2006 16:58:31 -0400 (EDT)

> On Tue, 3 Oct 2006, David Miller wrote:
> 
> > The socket policy behavior deserves some scrutiny.  I say this because
> > if a matching socket policy is avoided due to security layer error,
> > this could potentially make key manager problems very hard to
> > diagnose.
> 
> In this case, AVC denial messages would be logged to the audit log, so 
> there'd be an indication of what's going wrong.

Ok.
