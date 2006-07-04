From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: tiacx - don't use UTS_RELEASE
Date: Tue, 04 Jul 2006 11:27:27 +0200
Message-ID: <1152005247.3109.22.camel@laptopd505.fenrus.org>
References: <1152004080.3109.18.camel@laptopd505.fenrus.org>
	 <20060704022537.97f703b4.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:26346 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751256AbWGDJ13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 05:27:29 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060704022537.97f703b4.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-07-04 at 02:25 -0700, Andrew Morton wrote:
> On Tue, 04 Jul 2006 11:07:59 +0200
> Arjan van de Ven <arjan@infradead.org> wrote:
> 
> > patch below removes the use of UTS_RELEASE from the tiacx driver; there
> > is absolutely no reason for a driver to print the kernel version or use
> > the UTS_RELEASE field; in addition this field changes all the time so
> > this causes spurious rebuilds..
> 
> http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/gregkh-04-usb/usb-storage-uname-in-pr-sc-unneeded-message.patch did it too.
> 
> UTS_RELEASE doesn't change much.  It's "2.6.17".

no but the header that it's in changes all the time iirc, at least it
used to (one of those kbuild regenerated files)


