From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: openconnect triggers soft lockup in __skb_get_rxhash
Date: Mon, 17 Dec 2012 03:46:31 +0200
Message-ID: <20121217014631.GA23101@shutemov.name>
References: <20121217005616.GA23029@shutemov.name>
 <20121216.172214.687979484434537200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: maxk@qti.qualcomm.com, netdev@vger.kernel.org, dwmw2@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shutemov.name ([204.155.152.216]:37649 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990Ab2LQBpu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 20:45:50 -0500
Content-Disposition: inline
In-Reply-To: <20121216.172214.687979484434537200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 16, 2012 at 05:22:14PM -0800, David Miller wrote:
> 
> Already fixed in Linus's tree by:
> 
> From 499744209b2cbca66c42119226e5470da3bb7040 Mon Sep 17 00:00:00 2001

No, it's not. I use up-to-date (2a74dbb) Linus tree with the patch in and
still see the issue.

-- 
 Kirill A. Shutemov
