From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix *_DIAG_MAX constants
Date: Thu, 21 Mar 2013 11:14:37 -0400 (EDT)
Message-ID: <20130321.111437.2012746070698745131.davem@davemloft.net>
References: <1363875500-14574-1-git-send-email-avagin@openvz.org>
	<20130321144218.GF9046@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avagin@openvz.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xemul@parallels.com, edumazet@google.com,
	paulmck@linux.vnet.ibm.com, dhowells@redhat.com
To: tgraf@suug.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130321144218.GF9046@casper.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 21 Mar 2013 14:42:18 +0000

> On 03/21/13 at 06:18pm, Andrey Vagin wrote:
>> Follow the common pattern and define *_DIAG_MAX like:
>> 
>>         [...]
>>         __XXX_DIAG_MAX,
>> };
>> 
>> Because everyone is used to do:
>> 
>>         struct nlattr *attrs[XXX_DIAG_MAX+1];
>> 
>>         nla_parse([...], XXX_DIAG_MAX, [...]
>> 
>> Reported-by: Thomas Graf <tgraf@suug.ch>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Pavel Emelyanov <xemul@parallels.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
>> Cc: David Howells <dhowells@redhat.com>
>> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

So you're ACK'ing a patch that makes changes to files that don't even
exist in the repository?

Andrey, post a clean patch against 'net' that fixes these constants
for existing code, don't just assume that your original patch set is
applied and post changes relative to that.  That's not how we work.

After the bug fix for the existing cases goes in, you have to repost
your original patch set on top of that.
