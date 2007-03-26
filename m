From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Mon, 26 Mar 2007 16:14:59 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0703261612370.14914@d.namei>
References: <200703261939.l2QJd7X7012809@faith.austin.ibm.com>
 <Line.LNX.4.64.0703261600210.14555@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, eparis@redhat.com,
	selinux@tycho.nsa.gov
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:55280 "EHLO
	mail5.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbXCZUPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 16:15:03 -0400
In-Reply-To: <Line.LNX.4.64.0703261600210.14555@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Mar 2007, James Morris wrote:

> On Mon, 26 Mar 2007, Joy Latten wrote:
> 
> > Signed-off-by: Joy Latten<latten@austin.ibm.com>
> 
> This looks ok to me, although I have a couple of minor issues (which 
> should probably not stop it being merged):
> 
> > +			if ((err = security_xfrm_policy_delete(pol)) != 0) {
> 
> The value of 'err' is implicitly inverted several times in this function 
> (and similarly in the state flush one).  Something like
> 
> 	ret = (fn() != 0);

Oops, ignore the above.

The correct idiom is:

	err = fn();
	if (err) {
		/* handle error */
	}


Please use that, to reduce confusion :-)



- James
-- 
James Morris
<jmorris@namei.org>
