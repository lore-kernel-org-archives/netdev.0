From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 1/2] net: thunderx: Set recevie buffer page usage count in bulk
Date: Fri, 11 Mar 2016 22:34:19 +0530
Message-ID: <CA+sq2CeONG+Ja7cgxeh3bpkSg4c4XscKwKSmgsDx-=3HqYiM+w@mail.gmail.com>
References: <CA+sq2Cc44v_ggy=QLOX_FGt6uTv3Qo1KmqCeZ8=3G1COuWxAHw@mail.gmail.com>
	<20160310.124450.278421705870462421.davem@davemloft.net>
	<CA+sq2CeMQMnmGPUWoLrtPzGiJpvNTsR_WmQzQr5wFVC9b3LU-w@mail.gmail.com>
	<20160310.144812.2252397711464239518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160310.144812.2252397711464239518.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 11, 2016 at 1:18 AM, David Miller <davem@davemloft.net> wrote:
> From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
> Date: Thu, 10 Mar 2016 23:57:48 +0530
>
>> Difference between NIU driver and this patch is there it's
>> calculate split count, increment page count and then divide page into
>> buffers. Here it's divide page into buffers, have a counter which increments
>> at every split and then at the end do a atomic increment of page->_count.
>>
>> Any issue with this approach ?
>
> I guess not.

Okay, so can i assume you will consider the patch for merging if no
other comments
are received. Or do you want me to resubmit patches a fresh. ?
