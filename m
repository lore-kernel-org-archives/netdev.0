From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: kernel panic when only one unsecured port
 available
Date: Wed, 10 Oct 2007 01:44:47 -0700 (PDT)
Message-ID: <20071010.014447.48529225.davem@davemloft.net>
References: <470C8CF1.4050706@sw.ru>
	<m3bqb7l6b7.fsf@bandura.englab.brq.redhat.com>
	<470C8F8D.3080402@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aarapov@redhat.com, netdev@vger.kernel.org
To: den@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34120
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752781AbXJJIoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 04:44:44 -0400
In-Reply-To: <470C8F8D.3080402@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@sw.ru>
Date: Wed, 10 Oct 2007 12:38:37 +0400

> both versions of settings, your ones and my ones are _useless_ in real
> life. So, we do some sanity fixes. Am I right? If so, we must prevent
> all versions of OOPS (aka division by zero here).
> 
> I'll send my vision in a moment...

I agree with Denis that we should plug all of the holes when fixing
this.
