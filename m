From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: reset transport header if it was not
 set before transmission
Date: Tue, 19 Mar 2013 13:58:04 +0100
Message-ID: <514860DC.9020404@redhat.com>
References: <1363333305-54398-1-git-send-email-jasowang@redhat.com>  <1363333305-54398-2-git-send-email-jasowang@redhat.com>  <1363399851.29475.52.camel@edumazet-glaptop>  <20130317.121318.1869489921021513474.davem@davemloft.net>  <51482F55.8020900@redhat.com> <1363695234.21184.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363695234.21184.36.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/19/2013 01:13 PM, Eric Dumazet wrote:
> On Tue, 2013-03-19 at 17:26 +0800, Jason Wang wrote:
>> On 03/18/2013 12:13 AM, David Miller wrote:
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Fri, 15 Mar 2013 19:10:51 -0700
>>>
>>>> Any way we can avoid adding this to fast path, for people not using
>>>> macvtap and ixgbe ?
>>> Likewise I'd rather see macvtap be responsible for fixing this up by
>>> setting the transport header properly, and therfore sending well
>>> formed packets to the rest of the stack.
>>
>> Ok, haven't checked all other possibility but looks like packet needs to
>> be fixed also.
>
> Daniel, could you post your patches if ready ?

Yes, will post them in a couple of minutes.

> Jason, I believe you could reuse existing flow dissector once Daniel
> patches are in.
