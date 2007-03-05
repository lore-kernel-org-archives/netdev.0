From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [PATCH] xfrm_policy delete security check misplaced
Date: Mon, 5 Mar 2007 11:10:04 -0600
Message-ID: <001801c75f49$1e1989f0$cc0a010a@tcssec.com>
References: <Line.LNX.4.64.0703051139040.14821@d.namei>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'Eric Paris'" <eparis@parisplace.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Venkat Yekkirala" <vyekkirala@tcsfw4.tcs-sec.com>,
	<cxzhang@watson.ibm.com>, "Stephen Smalley" <sds@tycho.nsa.gov>
To: "'James Morris'" <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:33743 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbXCERKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 12:10:37 -0500
In-Reply-To: <Line.LNX.4.64.0703051139040.14821@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > 
> > > Signed-off-by: Eric Paris <eparis@redhat.com>
> > Acked-by: Venkat Yekkirala <vyekkirala@trustedcs.com> 
> 
> What about your previous comment:
> 
>  "I guess you meant to do this here?
>         else if (err)
>                 return err; "

I saw that this was taken care of in patch-2 for the delete case, but
while err isn't currently applicable to the non-delete case, it would
be proper/complete for err to still be handled for the non-delete case.
Thanks for asking.
