From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] be2net: fix mccq create for big endian
 architectures
Date: Mon, 15 Mar 2010 15:48:19 -0700 (PDT)
Message-ID: <20100315.154819.102922144.davem@davemloft.net>
References: <20100311113548.GA12029@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34496
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936990Ab0COWr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:47:57 -0400
In-Reply-To: <20100311113548.GA12029@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Thu, 11 Mar 2010 17:05:59 +0530

> The request to create an mccq was being dispatched without
> doing a byte swap of num_pages. This byte swap is necessary
> for Big Endian systems like PPC. Not having this fix leads
> mccq create to fail on BE ASICs running newer version of
> firmware, thereby causing driver initialization failure.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
