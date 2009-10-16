From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 6/8] trivial: fix typo s/refference/reference/ in
 comment
Date: Fri, 16 Oct 2009 18:08:17 +0200
Message-ID: <1255709297.31260.2.camel@localhost.localdomain>
References: <1255637783-6109-1-git-send-email-cascardo@holoscopio.com>
	 <alpine.LSU.2.00.0910161524480.8582@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Wang Chen <wangchen@cn.fujitsu.com>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:52191 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbZJPQIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 12:08:34 -0400
In-Reply-To: <alpine.LSU.2.00.0910161524480.8582@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

> On Thu, 15 Oct 2009, Thadeu Lima de Souza Cascardo wrote:
> 
> > diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
> > index cafe9f5..1bd9398 100644
> > --- a/net/bluetooth/bnep/core.c
> > +++ b/net/bluetooth/bnep/core.c
> > @@ -78,7 +78,7 @@ static struct bnep_session *__bnep_get_session(u8 *dst)
> >  static void __bnep_link_session(struct bnep_session *s)
> >  {
> >  	/* It's safe to call __module_get() here because sessions are added
> > -	   by the socket layer which has to hold the refference to this module.
> > +	   by the socket layer which has to hold the reference to this module.
> >  	 */
> >  	__module_get(THIS_MODULE);
> >  	list_add(&s->list, &bnep_session_list);
> 
> Merged together with patches 2-8 from your series and applied to trivial
> queue.

trivial, but neverless ...

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


