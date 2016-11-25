From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] cxgb4: fix memory leak on txq_info
Date: Fri, 25 Nov 2016 21:28:13 +0000
Message-ID: <6f2da092-213e-3c0b-d1be-97963b393f42@canonical.com>
References: <20161123110244.16111-1-colin.king@canonical.com>
 <20161125.161058.2283539123524395654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161125.161058.2283539123524395654.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25/11/16 21:10, David Miller wrote:
> From: Colin King <colin.king@canonical.com>
> Date: Wed, 23 Nov 2016 11:02:44 +0000
> 
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> Currently if txq_info->uldtxq cannot be allocated then
>> txq_info->txq is being kfree'd (which is redundant because it
>> is NULL) instead of txq_info. Fix this by instead kfree'ing
>> txq_info.
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> Applied, but Colin you _really_ need to start properly marking your
> networking patch submissions by indicating in the subject which
> tree your change is for.  In this case I figured out it was
> net-next, but you must say this explicitly in the Subject line
> via "Subject: [PATCH net-next] ..."
> 
> Thanks.
> 
Understood, will do next time, apologies for that.

Colin
