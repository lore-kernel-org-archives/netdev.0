From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9][TG3]: Add basic 5906 support.
Date: Wed, 27 Sep 2006 17:03:44 -0700 (PDT)
Message-ID: <20060927.170344.11385955.davem@davemloft.net>
References: <1159389299.3411.23.camel@rh4>
	<20060927.160836.74560378.davem@davemloft.net>
	<1159399261.3411.45.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19620
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031268AbWI1ADq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 20:03:46 -0400
To: mchan@broadcom.com
In-Reply-To: <1159399261.3411.45.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 27 Sep 2006 16:21:01 -0700

> It was found that on rare occasions, the 5906 will miss the first
> interrupt after reset without the COALESCE_NOW.  It was also felt that
> other chips may also have this problem, and therefore it is a good and a
> safe thing to do for all chips using the tagged mode.
> 
> This call is only made after resetting the chip, and so there's no
> performance impact at all during run-time.

Thanks for the explanation.
