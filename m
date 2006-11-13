From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] ambassador,firestream: "-1 >>" is implementation defined
Date: Mon, 13 Nov 2006 20:26:56 +0000
Message-ID: <20061113202656.GT29920@ftp.linux.org.uk>
References: <20061113202200.GA4971@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chas Williams <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:40398 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1755267AbWKMU1K
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 15:27:10 -0500
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20061113202200.GA4971@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 13, 2006 at 11:22:00PM +0300, Alexey Dobriyan wrote:
> 6.5.7(5): The result of E1 >> E2 is E1 right-shifted E2 bit positions.
> 		...
> 	If E1 has a signed type and a negative value, the resulting value
> 	is implementation defined.
> 
> So, cast -1 to unsigned type to make result well-defined.

Or just use ~0U and be done with that.
