From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 0/3] bonding: fix bond_3ad RCU usage
Date: Thu, 9 Jan 2014 11:56:53 +0100
Message-ID: <20140109105653.GE5786@redhat.com>
References: <1389264510-22141-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750882AbaAILAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 06:00:52 -0500
Content-Disposition: inline
In-Reply-To: <1389264510-22141-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 11:48:27AM +0100, Veaceslav Falico wrote:
>While digging through bond_3ad.c I've found that the RCU usage there is
>just wrong - it's used as a kind of mutex/spinlock instead of RCU.
>
>This patchset is on top of bond_3ad.c cleanup:
>http://www.spinics.net/lists/netdev/msg265447.html

Self-NAK, seems like I've missed some locks. Sorry for the noise/early
posting, will post v2 soon.

>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>CC: netdev@vger.kernel.org
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
