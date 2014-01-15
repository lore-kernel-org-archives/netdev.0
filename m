From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 10/10] net: nl80211: __dev_get_by_index instead
 of dev_get_by_index to find interface
Date: Wed, 15 Jan 2014 09:18:05 +0800
Message-ID: <52D5E1CD.2020405@windriver.com>
References: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>	 <1389685269-18600-11-git-send-email-ying.xue@windriver.com> <1389701498.23430.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <vfalico@redhat.com>,
	<john.r.fastabend@intel.com>, <stephen@networkplumber.org>,
	<antonio@meshcoding.com>, <dmitry.tarnyagin@lockless.no>,
	<socketcan@hartkopp.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389701498.23430.1.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/14/2014 08:11 PM, Johannes Berg wrote:
> On Tue, 2014-01-14 at 15:41 +0800, Ying Xue wrote:
> 
>> @@ -2218,10 +2194,6 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
>>  			rdev->wiphy.coverage_class = old_coverage_class;
>>  		}
>>  	}
>> -
>> - bad_res:
>> -	if (netdev)
>> -		dev_put(netdev);
>>  	return result;
> 
> I believe that could be "return 0;" now, which would make the code
> easier to read.
> 

Yes, I will change it in next version.

Thanks,
Ying

> johannes
> 
> 
> 
