From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v5 2/3] sysctl: add proc_do_large_bitmap
Date: Fri, 26 Feb 2010 10:26:59 +0800
Message-ID: <4B873173.80400@redhat.com>
References: <1267095756.12391.6.camel@Nokia-N900-42-11>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: opurdila@ixiacom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267095756.12391.6.camel@Nokia-N900-42-11>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Octavian Purdila wrote:
>> I think one of them is enough, since we already chose commas, why
>> do we need to add spaces? If you have some strong reason to add it,
>> I have no objections.
>>
> 
> It is just for simpler implementation. It is actually harder to restrict the separator to only commas insted of allowing both spaces and commas, because I rely on functions used for the integer vector handling. 
> 
> Maybe I should change those functions to be more generic and thus to allow more stricter input, but I am not sure if its worth it. Isn't a more permissive input format desirable?

I think you should ask Eric, since he proposed using commas. :)
I am fine with either of them.

Thanks.
