From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [stable] [BK PATCHES] 2.6.x net driver oops fixes
Date: Thu, 10 Mar 2005 15:29:24 -0500
Message-ID: <4230AE24.602@pobox.com>
References: <422F59E8.2090707@pobox.com> <20050310202548.GV5389@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>,
        Netdev <netdev@oss.sgi.com>, stable@kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Roger Luethi <rl@hellgate.ch>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050310202548.GV5389@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Wright wrote:
> * Jeff Garzik (jgarzik@pobox.com) wrote:
> 
> 
>>This will update the following files:
>>
>> drivers/net/sis900.c    |   41 +++++++++++++++++++++--------------------
>> drivers/net/via-rhine.c |    3 +++
> 
> 
> The via-rhine fix is already in the stable queue.  But the sis900 oops
> fix does not apply to the stable tree.  It relies on a few intermediate
> patches.  Appears to still be an issue for the older version which is in
> 2.6.11.  Here's a stab at a backport.  Would you like to review/validate
> or drop this one?

The backport looks correct to me, though it would be nice to get a 
via-rhine owner to ACK the patch before it goes in...

	Jeff
