From: Eric Paris <eparis@parisplace.org>
Subject: RE: [PATCH] xfrm_policy delete security check misplaced
Date: Mon, 05 Mar 2007 11:51:28 -0500
Message-ID: <1173113488.31047.36.camel@localhost.localdomain>
References: <001501c75f3f$243a3000$cc0a010a@tcssec.com>
	 <Line.LNX.4.64.0703051139040.14821@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Venkat Yekkirala <vyekkirala@tcsfw4.tcs-sec.com>,
	cxzhang@watson.ibm.com, Stephen Smalley <sds@tycho.nsa.gov>
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933203AbXCEVOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 16:14:35 -0500
In-Reply-To: <Line.LNX.4.64.0703051139040.14821@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-03-05 at 11:39 -0500, James Morris wrote:
> On Mon, 5 Mar 2007, Venkat Yekkirala wrote:
> 
> > > 
> > > Signed-off-by: Eric Paris <eparis@redhat.com>
> > Acked-by: Venkat Yekkirala <vyekkirala@trustedcs.com> 
> 
> What about your previous comment:
> 
>  "I guess you meant to do this here?
>         else if (err)
>                 return err; "

That also gets taken care of in the pfkey_spdget cleanup in a later
patch.  The return isn't in that same place venkat suggested it instead
happens inside the new if (delete) block.  (err is only non-zero on
delete operations so there is no need to check it otherwise)

-Eric

