From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: fix horizon init section usage
Date: Tue, 24 Oct 2006 16:17:01 -0700 (PDT)
Message-ID: <20061024.161701.35357228.davem@davemloft.net>
References: <453C45D4.6080904@oracle.com>
	<20061022.213955.85411282.davem@davemloft.net>
	<453CEE76.6080700@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:493
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422809AbWJXXQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 19:16:56 -0400
To: randy.dunlap@oracle.com
In-Reply-To: <453CEE76.6080700@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Randy.Dunlap" <randy.dunlap@oracle.com>
Date: Mon, 23 Oct 2006 09:31:50 -0700

> FYI:  read_bia() also needs to be changed from __init to __devinit
> since it's called from hrz_init().

Thanks Randy, I've fixed this up in my tree too.
