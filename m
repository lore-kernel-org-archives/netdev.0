From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 0/3] Kill arch_fast_hash
Date: Thu, 11 Dec 2014 00:15:01 +0100
Message-ID: <5488D3F5.8040701@redhat.com>
References: <1418225592-29322-1-git-send-email-dborkman@redhat.com> <20141210.151838.1178381810877719493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758230AbaLJXaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 18:30:08 -0500
In-Reply-To: <20141210.151838.1178381810877719493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2014 09:18 PM, David Miller wrote:
...
> Series applied, and I'll queue patch #1 to -stable, thanks.

Sounds good, thanks!

Btw, this will create a "silent" merge conflict with Linus' tree:
As nios2 arch has been merged for 3.19, the 'generic-y += hash.h'
from arch/nios2/include/asm/Kbuild needs to be removed there, too.
