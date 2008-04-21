From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [DCCP]: Convert do_gettimeofday() to getnstimeofday().
Date: Mon, 21 Apr 2008 14:28:57 -0700 (PDT)
Message-ID: <20080421.142857.234288906.davem@davemloft.net>
References: <20080421.162227.63020853.yoshfuji@linux-ipv6.org>
	<20080421.023503.242108516.davem@davemloft.net>
	<20080421134844.GC12221@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52503
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751945AbYDUV2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 17:28:55 -0400
In-Reply-To: <20080421134844.GC12221@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 21 Apr 2008 10:48:44 -0300

> Em Mon, Apr 21, 2008 at 02:35:03AM -0700, David Miller escreveu:
> > From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> > Date: Mon, 21 Apr 2008 16:22:27 +0900 (JST)
> > 
> > > What do_gettimeofday() does is to call getnstimeofday() and
> > > to convert the result from timespec{} to timeval{}.
> > > We do not always need timeval{} and we can convert timespec{}
> > > when we really need (to print).
> > > 
> > > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > 
> > This looks good too, but I'll be polite and wait for any
> > DCCP maintainer ACKs :-)
> 
> Thanks everybody:
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Thanks for reviewing, patch applied.
