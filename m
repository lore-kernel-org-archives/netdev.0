From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm_user: return error pointer instead of NULL #2
Date: Tue, 18 Sep 2012 16:16:29 -0400 (EDT)
Message-ID: <20120918.161629.143875439883330517.davem@davemloft.net>
References: <1347652712-14584-1-git-send-email-minipli@googlemail.com>
	<20120917071853.GD13023@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: minipli@googlemail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120917071853.GD13023@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 17 Sep 2012 09:18:53 +0200

> On Fri, Sep 14, 2012 at 09:58:32PM +0200, Mathias Krause wrote:
>> When dump_one_policy() returns an error, e.g. because of a too small
>> buffer to dump the whole xfrm policy, xfrm_policy_netlink() returns
>> NULL instead of an error pointer. But its caller expects an error
>> pointer and therefore continues to operate on a NULL skbuff.
>> 
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> 
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable.
