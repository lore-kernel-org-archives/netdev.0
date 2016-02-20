From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] af_unix: Don't use continue to re-execute
 unix_stream_read_generic loop
Date: Fri, 19 Feb 2016 23:51:07 -0500 (EST)
Message-ID: <20160219.235107.1810934052787203460.davem@davemloft.net>
References: <877fi2gpkd.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	hannes@stressinduktion.org, joseph.salisbury@canonical.com,
	edumazet@google.com
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877fi2gpkd.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Thu, 18 Feb 2016 12:39:46 +0000

> The unix_stream_read_generic function tries to use a continue statement
> to restart the receive loop after waiting for a message. This may not
> work as intended as the caller might use a recvmsg call to peek at
> control messages without specifying a message buffer. If this was the
> case, the continue will cause the function to return without an error
> and without the credential information if the function had to wait for a
> message while it had returned with the credentials otherwise. Change to
> using goto to restart the loop without checking the condition first in
> this case so that credentials are returned either way.
> 
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
