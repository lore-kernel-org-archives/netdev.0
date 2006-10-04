From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Tue, 3 Oct 2006 21:33:17 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610032132050.27760@d.namei>
References: <20061002134200.GA20441@2ka.mipt.ru> <Pine.LNX.4.64.0610021004180.9739@d.namei>
 <Pine.LNX.4.64.0610021020390.9909@d.namei> <20061003.161807.18306641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, sds@tycho.nsa.gov,
	vyekkirala@TrustedCS.com, paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:10680 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030690AbWJDBdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 21:33:19 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061003.161807.18306641.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Oct 2006, David Miller wrote:

> I'm not saying either is wrong, I'm just pointing it out to make sure
> this is intentional.
> 
> The socket policy behavior deserves some scrutiny.  I say this because
> if a matching socket policy is avoided due to security layer error,
> this could potentially make key manager problems very hard to
> diagnose.

Yep, the code needs to be reworked in general (Venkat is doing this).



- James
-- 
James Morris
<jmorris@namei.org>
