From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: filter: add insn for loading internal transport
 header offset
Date: Thu, 01 May 2014 12:53:53 +0200
Message-ID: <536227C1.20309@redhat.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408AbaEAKyD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 06:54:03 -0400
In-Reply-To: <1398882591-30422-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Chema, please also keep me in cc if possible. ]

On 04/30/2014 08:29 PM, Chema Gonzalez wrote:
> Patch adds an ANC_TRA_OFFSET insn that loads the internal transport
> header of a packet ("internal" meaning after decapsulation by the
> flow dissector).
>
> Signed-off-by: Chema Gonzalez <chema@google.com>

Looks good to me. For casting pointers as Dave noted recently, please
use 'unsigned long'. This needs to be fixed in other places as well.

Other than that, you can add my:

Acked-by: Daniel Borkmann <dborkman@redhat.com>
