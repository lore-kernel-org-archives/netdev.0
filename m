From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [PATCH] xfrm audit hook misplaced in pfkey_delete and xfrm_del_sa
Date: Mon, 5 Mar 2007 10:00:51 -0600
Message-ID: <001701c75f3f$73937350$cc0a010a@tcssec.com>
References: <1172866536.31047.32.camel@localhost.localdomain>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jmorris@namei.org>,
	"Venkat Yekkirala" <vyekkirala@tcsfw4.tcs-sec.com>,
	<cxzhang@watson.ibm.com>, <sds@tycho.nsa.gov>
To: "'Eric Paris'" <eparis@parisplace.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:49057 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933587AbXCEQBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 11:01:07 -0500
In-Reply-To: <1172866536.31047.32.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Inside pfkey_delete and xfrm_del_sa the audit hooks were not called if
> there was any permission/security failures in attempting to do the del
> operation (such as permission denied from security_xfrm_state_delete).
> This patch moves the audit hook to the exit path such that 
> all failures
> (and successes) will actually get audited.

Not sure ALL failures are being audited this way elsewhere, but I guess
they would catchup in course of time.

> 
> Signed-off-by: Eric Paris <eparis@redhat.com>
Acked-by: Venkat Yekkirala <vyekkirala@trustedcs.com> 
