From: Andrew Morton <akpm@osdl.org>
Subject: Re: tiacx - don't use UTS_RELEASE
Date: Tue, 4 Jul 2006 02:25:37 -0700
Message-ID: <20060704022537.97f703b4.akpm@osdl.org>
References: <1152004080.3109.18.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50147 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751250AbWGDJZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 05:25:50 -0400
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1152004080.3109.18.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 04 Jul 2006 11:07:59 +0200
Arjan van de Ven <arjan@infradead.org> wrote:

> patch below removes the use of UTS_RELEASE from the tiacx driver; there
> is absolutely no reason for a driver to print the kernel version or use
> the UTS_RELEASE field; in addition this field changes all the time so
> this causes spurious rebuilds..

http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/gregkh-04-usb/usb-storage-uname-in-pr-sc-unneeded-message.patch did it too.

UTS_RELEASE doesn't change much.  It's "2.6.17".
