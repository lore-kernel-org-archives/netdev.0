From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] econet: 4 byte infoleak to the network
Date: Fri, 18 Mar 2011 15:15:32 -0700 (PDT)
Message-ID: <20110318.151532.52204604.davem@davemloft.net>
References: <1300362011-8653-1-git-send-email-segoon@openwall.com>
	<1300362601.2132.14721.camel@phil-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: segoon@openwall.com, linux-kernel@vger.kernel.org,
	security@kernel.org, eric.dumazet@gmail.com, tj@kernel.org,
	nelhage@ksplice.com, netdev@vger.kernel.org
To: philb@gnu.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300362601.2132.14721.camel@phil-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Blundell <philb@gnu.org>
Date: Thu, 17 Mar 2011 11:50:01 +0000

> On Thu, 2011-03-17 at 14:40 +0300, Vasiliy Kulikov wrote:
>> struct aunhdr has 4 padding bytes between 'pad' and 'handle' fields on
>> x86_64.  These bytes are not initialized in the variable 'ah' before
>> sending 'ah' to the network.  This leads to 4 bytes kernel stack
>> infoleak.
>> 
>> This bug was introduced before the git epoch.
>> 
>> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> 
> Well spotted.  Thanks for the patch.
> 
> Acked-by: Phil Blundell <philb@gnu.org>

Applied.
