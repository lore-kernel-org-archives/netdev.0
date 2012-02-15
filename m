From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH V4 12/13] netfront: multi page ring support.
Date: Wed, 15 Feb 2012 18:53:35 -0500
Message-ID: <20120215235335.GA8440@phenom.dumpdata.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
 <1328201363-13915-13-git-send-email-wei.liu2@citrix.com>
 <20120215224253.GA18762@phenom.dumpdata.com>
 <20120215.175212.1236819573371947275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wei.liu2@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com, ian.campbell@citrix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:40049 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033Ab2BOX4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 18:56:47 -0500
Content-Disposition: inline
In-Reply-To: <20120215.175212.1236819573371947275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2012 at 05:52:12PM -0500, David Miller wrote:
> From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Date: Wed, 15 Feb 2012 17:42:53 -0500
> 
> > @@ -29,6 +29,8 @@
> >   * IN THE SOFTWARE.
> >   */
> >  
> > +#define DEBUG 1
> > +
> >  #include <linux/module.h>
> >  #include <linux/kernel.h>
> >  #include <linux/netdevice.h>
> 
> This is never appropriate.

HA! No it is not. Thanks for spotting it.

I was thinking that Liu would actually squash the fix the patch I responded to.
