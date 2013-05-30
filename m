From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] bonding: change igmp_retrans type from s8 to u8
Date: Thu, 30 May 2013 10:57:48 +0200
Message-ID: <51A7148C.7060103@redhat.com>
References: <1369839734-7131-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24312 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967933Ab3E3I6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 04:58:01 -0400
In-Reply-To: <1369839734-7131-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/05/13 17:02, nikolay@redhat.com wrote:
> From: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> According to the bonding documentation and to the error messages the
> resend_igmp should be between 0 and 255, but since the type of the
> variable that counts is wrong, this is not the case.
> We have igmp_retrans = resend_igmp when the work is started.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
Self-NACK, there's another related bug and this is not a full fix.
Dave please don't apply this patch, I'll resend a proper fix.

Nik
