From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Thu, 5 Oct 2006 16:58:31 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610051657270.25705@d.namei>
References: <20061002134200.GA20441@2ka.mipt.ru> <Pine.LNX.4.64.0610021004180.9739@d.namei>
 <Pine.LNX.4.64.0610021020390.9909@d.namei> <20061003.161807.18306641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, sds@tycho.nsa.gov,
	vyekkirala@TrustedCS.com, paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:46219 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751347AbWJEU6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 16:58:33 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061003.161807.18306641.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Oct 2006, David Miller wrote:

> The socket policy behavior deserves some scrutiny.  I say this because
> if a matching socket policy is avoided due to security layer error,
> this could potentially make key manager problems very hard to
> diagnose.

In this case, AVC denial messages would be logged to the audit log, so 
there'd be an indication of what's going wrong.


- James
-- 
James Morris
<jmorris@namei.org>
