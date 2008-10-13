From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] IPROUTE: tc correct error message
Date: Mon, 13 Oct 2008 07:00:27 -0700
Message-ID: <20081013070027.71b74bf6@extreme>
References: <48D7A324.3050401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marcela Maslanova <mmaslano@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36950 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215AbYJMOAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 10:00:31 -0400
In-Reply-To: <48D7A324.3050401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This warning message was removed in change 
083a5f00a15f6506815b0da2be82e7be761c5cbc
In this patch is checked, whether warning should be printed. Output
of "tc filter <type> help" isn't spoiled after my change.
-- 


Actually, protocol is not required. It defaults to all.
But I did go ahead and make help just return.
