From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: filter: return -EINVAL if BPF_S_ANC* operation is
 not supported
Date: Wed, 12 Dec 2012 10:38:01 +0100
Message-ID: <50C85079.4010209@redhat.com>
References: <1355304701-22228-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ani Sinha <ani@aristanetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752865Ab2LLJiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 04:38:06 -0500
In-Reply-To: <1355304701-22228-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2012 10:31 AM, Daniel Borkmann wrote:
> Currently, we return -EINVAL for malicious or wrong BPF filters.
> However, this is not done for BPF_S_ANC* operations, which makes it
> more difficult to detect if it's actually supported or not by the
> BPF machine. Therefore, we should also return -EINVAL if K is within
> the SKF_AD_OFF universe and the ancillary operation did not match.
>
> Cc: Ani Sinha <ani@aristanetworks.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

(Sorry, this is intended for net-next.)
