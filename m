From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC patch net-next] ipv4: use bcast as dst address in case IFF_NOARP is set
Date: Tue, 08 Jan 2013 09:11:55 -0800 (PST)
Message-ID: <7abb4995-17a4-49ca-b0a7-41af6ff763e1@tahiti.vyatta.com>
References: <1357650162-5554-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59750 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756231Ab3AHRL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 12:11:59 -0500
In-Reply-To: <1357650162-5554-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> When IFF_NOARP is set on a device, dev->dev_addr is used as *dst*
> addr of sent frames. That does not make sense. Use rather bcast
> address
> instead.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

What did you test this on? I think this may have been
intentional to avoid broadcasting.
