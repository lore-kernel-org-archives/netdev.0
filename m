From: "Baxter, Jim" <jim_baxter@mentor.com>
Subject: Re: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Mon, 22 May 2017 16:45:42 +0100
Message-ID: <04bc5b49-9282-a6ca-2b95-fb8fc9750555@mentor.com>
References: <1494956480-6127-1-git-send-email-jim_baxter@mentor.com>
 <1494956480-6127-2-git-send-email-jim_baxter@mentor.com>
 <87shk4fynp.fsf@miraculix.mork.no>
 <20170517.141819.1307166900606639947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <oliver@neukum.org>
To: David Miller <davem@davemloft.net>, <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517.141819.1307166900606639947.davem@davemloft.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David S. Miller (davem@davemloft.net)
Sent: Wed, 17 May 2017 14:18:19 -0400 

> 
> When there isn't memory pressure this will hurt performance of
> course.
> 
> It is a quite common paradigm to back down to 0 order memory requests
> when higher order ones fail, so this isn't such a bad change from the
> perspective.
> 
> However, one negative about it is that when the system is under memory
> stress it doesn't help at all to keep attemping high order allocations
> when the system hasn't recovered yet.  In fact, this can make it
> worse.
> 

Hello David,

Do you think the patch should be modified to extend the length of time
the 0 order memory requests with a time period of 1 minute for example?

Or do you feel the patch is not the correct way this should be performed?

Best regards,
Jim
