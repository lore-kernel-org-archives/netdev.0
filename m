From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 0/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Sun, 8 Oct 2006 14:35:40 +0400
Message-ID: <20061008103540.GA25580@2ka.mipt.ru>
References: <45256E25.6020201@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov, eparis@redhat.com, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44472 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751057AbWJHKgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2006 06:36:15 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
Content-Disposition: inline
In-Reply-To: <45256E25.6020201@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 03:42:13PM -0500, Venkat Yekkirala (vyekkirala@trustedcs.com) wrote:
> This version takes into account David Miller's comments
> regarding treatment of security layer errors in the case
> of socket policies. Specifically, these errors will be
> treated like how these kind of errors are treated for
> the main/sub policies, which is to return a full lookup
> failure.

I applied all three patches and rerun my acrypto tests, which do not
show any unencrypted packets anymore, so I ack this changes since they
fix the problem.
Thanks.

-- 
	Evgeniy Polyakov
