From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [PATCH 3/3] mlsxfrm: Various fixes
Date: Wed, 8 Nov 2006 08:34:34 -0600
Message-ID: <000601c70343$02fa9fe0$cc0a010a@tcssec.com>
References: <1162932520.3009.58.camel@moss-spartans.epoch.ncsc.mil>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:33843 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S965804AbWKHOe7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 09:34:59 -0500
To: "'Stephen Smalley'" <sds@tycho.nsa.gov>,
	"Paul Moore" <paul.moore@hp.com>
In-Reply-To: <1162932520.3009.58.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Such duplication can occur among the initial SIDs.

For some reason I thought that could happen between an initial SID
and a non-initial SID.

>  Not sure 
> though when
> that would apply here,

It could apply to xfrms if they happen to be using the context
represented by any of the initial SIDs.

> and it would only apply if both SIDs 
> were initial
> SIDs.

OK. Will narrow the full context comparison to just this case.
