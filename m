From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 3 Aug 2006 10:52:22 -0400
Message-ID: <20060803145222.GB14997@kvack.org>
References: <44D1FEB7.2050703@arndnet.de> <20060803142412.GA14997@kvack.org> <Pine.LNX.4.64.0608031646110.8443@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Hannemann <arnd@arndnet.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:23737 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S932546AbWHCOwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 10:52:41 -0400
To: Krzysztof Oledzki <olel@ans.pl>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0608031646110.8443@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 04:49:15PM +0200, Krzysztof Oledzki wrote:
> With 1 GB of RAM full 1GB/3GB (CONFIG_VMSPLIT_3G_OPT) seems to be 
> enough...

Nope, you lose ~128MB of RAM for vmalloc space.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
