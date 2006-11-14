From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ambassador,firestream: "-1 >>" is implementation
 defined
Date: Mon, 13 Nov 2006 16:12:34 -0800 (PST)
Message-ID: <20061113.161234.88477152.davem@davemloft.net>
References: <20061113202200.GA4971@martell.zuzino.mipt.ru>
	<20061113202656.GT29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27561
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933212AbWKNAM0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 19:12:26 -0500
To: viro@ftp.linux.org.uk
In-Reply-To: <20061113202656.GT29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>
Date: Mon, 13 Nov 2006 20:26:56 +0000

> On Mon, Nov 13, 2006 at 11:22:00PM +0300, Alexey Dobriyan wrote:
> > 6.5.7(5): The result of E1 >> E2 is E1 right-shifted E2 bit positions.
> > 		...
> > 	If E1 has a signed type and a negative value, the resulting value
> > 	is implementation defined.
> > 
> > So, cast -1 to unsigned type to make result well-defined.
> 
> Or just use ~0U and be done with that.

I've modified the patch based upon Al's suggestion and applied
it to 2.6.20, thanks everyone.
