From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun: fix recovery from gup errors
Date: Tue, 25 Jun 2013 16:24:29 -0700 (PDT)
Message-ID: <20130625.162429.966445706450575614.davem@davemloft.net>
References: <20130623141903.GA21029@redhat.com>
	<51C7BB8C.70304@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, linux-kernel@vger.kernel.org, edumazet@google.com,
	nhorman@tuxdriver.com, netdev@vger.kernel.org, bhubbard@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C7BB8C.70304@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 24 Jun 2013 11:22:52 +0800

> On 06/23/2013 10:19 PM, Michael S. Tsirkin wrote:
>> get user pages might fail partially in tun zero copy
>> mode. To recover we need to put all pages that we got,
>> but code used a wrong index resulting in double-free
>> errors.
>>
>> Reported-by: Brad Hubbard <bhubbard@redhat.com>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> ---
>>
>> I haven't figured out why do we get failures,
>> but recovery is clearly wrong.
>>
>> This is also -stable material.
> 
> Acked-by: Jason Wang <jasowang@redhat.com>

Applied with the missing empty line added, I was tired of waiting for
Michael to take care of this himself.
