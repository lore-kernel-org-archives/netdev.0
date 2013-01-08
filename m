From: David Miller <davem@davemloft.net>
Subject: Re: [RFC patch net-next] ipv4: use bcast as dst address in case
 IFF_NOARP is set
Date: Tue, 08 Jan 2013 14:27:37 -0800 (PST)
Message-ID: <20130108.142737.1239088077093843462.davem@davemloft.net>
References: <1357650162-5554-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, shemminger@vyatta.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695Ab3AHW1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 17:27:39 -0500
In-Reply-To: <1357650162-5554-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  8 Jan 2013 14:02:42 +0100

> When IFF_NOARP is set on a device, dev->dev_addr is used as *dst*
> addr of sent frames. That does not make sense. Use rather bcast address
> instead.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

The address is actually arbitrary in this case, I believe the
current behavior is intentional, and even if it is not intentional
since the address is arbitrary this change carrys only potential
risk for zero gain.
