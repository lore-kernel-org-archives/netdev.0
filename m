From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 net-next] tc: m_csum: add support for SCTP
 checksum
Date: Thu, 19 Jan 2017 19:24:55 +0100
Message-ID: <20170119192455.302d215a@griffin>
References: <d979c4187228759f94c3b6c8504b16783e03bdc6.1484846369.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Gregoire Baron <baronchon@n7mm.org>, netdev@vger.kernel.org
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45370 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751622AbdASSY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 13:24:59 -0500
In-Reply-To: <d979c4187228759f94c3b6c8504b16783e03bdc6.1484846369.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2017 18:26:42 +0100, Davide Caratti wrote:
> 'sctp' parameter can now be used as 'csum' target to enable CRC32c
> computation on SCTP packets.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> ---
>  tc/m_csum.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)

Please also update the tc-csum.8 man page.

Thanks,

 Jiri
