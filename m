From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] ieee802154: fix __init functions
Date: Wed, 01 Oct 2014 02:02:51 -0400 (EDT)
Message-ID: <20141001.020251.105468714011560897.davem@davemloft.net>
References: <1412141266-12258-1-git-send-email-fabf@skynet.be>
	<56FE06A5-5C2A-42E4-B01A-15EB36BAADE5@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabf@skynet.be, linux-kernel@vger.kernel.org, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56FE06A5-5C2A-42E4-B01A-15EB36BAADE5@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Wed, 1 Oct 2014 07:34:39 +0200

> Hi Fabian,
> 
>> Commit 3243acd37fd9
>> ("ieee802154: add __init to lowpan_frags_sysctl_register")
>> 
>> added __init to lowpan_frags_ns_sysctl_register instead of
>> lowpan_frags_sysctl_register
>> 
>> Suggested-by: Alexander Aring <alex.aring@gmail.com>
>> Signed-off-by: Fabian Frederick <fabf@skynet.be>
>> ---
>> net/ieee802154/reassembly.c | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> when trying to apply this to bluetooth-next kernel, I am getting this:
> 
> Applying: ieee802154: fix __init functions
> error: patch failed: net/ieee802154/reassembly.c:498
> error: net/ieee802154/reassembly.c: patch does not apply
> Patch failed at 0001 ieee802154: fix __init functions

You haven't been following the conversation.

I already applied his previous patch which had errors to net-next,
so this is a patch relative to net-next which fixes things and
implements the change correctly.
