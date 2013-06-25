From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvtap: fix recovery from gup errors
Date: Tue, 25 Jun 2013 16:24:58 -0700 (PDT)
Message-ID: <20130625.162458.961275537627752359.davem@davemloft.net>
References: <20130623142658.GA21141@redhat.com>
	<51C7BBA3.1050300@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, linux-kernel@vger.kernel.org, edumazet@google.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bhubbard@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C7BBA3.1050300@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 24 Jun 2013 11:23:15 +0800

> On 06/23/2013 10:26 PM, Michael S. Tsirkin wrote:
>> get user pages might fail partially in macvtap zero copy
>> mode. To recover we need to put all pages that we got,
>> but code used a wrong index resulting in double-free
>> errors.
>>
>> Reported-by: Brad Hubbard <bhubbard@redhat.com>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> ---
>>
>> Same as the tun patch really. Also stable material.
> 
> Acked-by: Jason Wang <jasowang@redhat.com>

Applied, also with the missing empty line added.
