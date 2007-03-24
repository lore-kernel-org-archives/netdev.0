From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [irda-users] [2.6.20-rt8] "Neighbour table overflow."
Date: Sat, 24 Mar 2007 02:36:08 +0200
Message-ID: <20070324003608.GB4494@sortiz.org>
References: <FuqKSqqx.1174476366.8345250.samuel@sortiz.org> <Pine.LNX.4.63.0703211235220.534@pcgl.dsa-ac.de> <Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "irda-users@lists.sourceforge.net" <irda-users@lists.sourceforge.net>,
	Paul Mackerras <paulus@samba.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Guennadi Liakhovetski <gl@dsa-ac.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.orange.fr ([193.252.22.23]:27517 "EHLO smtp25.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924AbXCXAgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 20:36:11 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 23, 2007 at 01:14:43PM +0100, Guennadi Liakhovetski wrote:
> On Wed, 21 Mar 2007, Guennadi Liakhovetski wrote:
> 
> > On Wed, 21 Mar 2007, Samuel Ortiz wrote:
> >
> >> I'm quite sure the leak is in the IrDA code rather than in the ppp or
> >> ipv4 one, hence the need for full irda debug...
> 
> Well, looks like you were wrong, Samuel. 
Heh, it's good to be wrong sometimes :-)

> Below is a patch that fixes ONE 
> sk_buff leak (maintainer added to cc: hi, Paul:-)). Still investigating if 
> there are more there.
Are you still seeing the skb cache growing with your fix ?

Cheers,
Samuel.

