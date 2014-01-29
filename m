From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: Re: 8% performance improved by change tap interact with kernel stack
Date: Wed, 29 Jan 2014 15:41:24 +0800
Message-ID: <52E8B0A4.6030806@huawei.com>
References: <52E766D4.4070901@huawei.com> <20140128083459.GB16833@redhat.com> <52E77506.1080604@huawei.com> <20140128094138.GA17332@redhat.com> <52E78416.50000@huawei.com> <20140128103325.GA17794@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <jasowang@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20140128103325.GA17794@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/1/28 18:33, Michael S. Tsirkin wrote:

>>> Nice.
>>> What about CPU utilization?
>>> It's trivially easy to speed up networking by
>>> burning up a lot of CPU so we must make sure it's
>>> not doing that.
>>> And I think we should see some tests with TCP as well, and
>>> try several message sizes.
>>>
>>>
>> Yes, by burning up more CPU we could get better performance easily.
>> So I have bond vhost thread and interrupt of nic on CPU1 while testing.
>>
>> modified before, the idle of CPU1 is 0%-1% while testing.
>> and after modify, the idle of CPU1 is 2%-3% while testing
>>
>> TCP also could gain from this, but pps is less than UDP, so I think
>> the improvement would be not so obviously.
>
> Still need to test this doesn't regress but overall looks convincing to me.
> Could you send a patch, accompanied by testing results for
> throughput latency and cpu utilization for tcp and udp
> with various message sizes?
>
> Thanks!
>
because of spring festival of china, the test result would be given two 
week later.
throughput would be test by netperf, and latency would be tested by 
qperf. Is that OK?

