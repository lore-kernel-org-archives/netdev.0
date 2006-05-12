From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 4/6] myri10ge - First half of the driver
Date: Fri, 12 May 2006 10:47:11 +0400
Message-ID: <20060512064710.GA27065@2ka.mipt.ru>
References: <446259A0.8050504@myri.com> <Pine.GSO.4.44.0605101438410.498-100000@adel.myri.com> <20060510231347.GC25334@electric-eye.fr.zoreil.com> <4463CE88.20301@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56276 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751012AbWELGrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 02:47:24 -0400
To: Brice Goglin <brice@myri.com>
Content-Disposition: inline
In-Reply-To: <4463CE88.20301@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 12, 2006 at 01:53:44AM +0200, Brice Goglin (brice@myri.com) wrote:
> > Imho you will want to work directly with pages shortly.
> >   
> 
> We had thought about doing this, but were a little nervous since we did
> not know of any other drivers that worked directly with pages.  If this
> is an official direction to work directly with pages, we will. 

s2io does. e1000 does it with skb frags.
If your hardware allows header split and driver can put headers into
skb->data and real data into frag_list, that allows to create various
interesting things like receiving zero-copy support and netchannels
support. It is work in progress, not official direction currently,
but this definitely will help your driver to support future high 
performance extensions.

> Brice

-- 
	Evgeniy Polyakov
