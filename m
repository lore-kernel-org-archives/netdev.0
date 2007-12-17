From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Mon, 17 Dec 2007 15:18:37 -0500
Message-ID: <4766D99D.5090507@garzik.org>
References: <20071216043148.GE3096@tuxdriver.com> <20071217193402.GD3121@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071217193402.GD3121-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Sat, Dec 15, 2007 at 11:31:48PM -0500, John W. Linville wrote:
> 
>> Cyrill Gorcunov (2):
>>       ieee80211_rate: missed unlock
> 
>>  net/mac80211/ieee80211_rate.c                  |    1 +
> 
>> diff --git a/net/mac80211/ieee80211_rate.c b/net/mac80211/ieee80211_rate.c
>> index 7254bd6..3260a4a 100644
>> --- a/net/mac80211/ieee80211_rate.c
>> +++ b/net/mac80211/ieee80211_rate.c
>> @@ -33,6 +33,7 @@ int ieee80211_rate_control_register(struct rate_control_ops *ops)
>>  		if (!strcmp(alg->ops->name, ops->name)) {
>>  			/* don't register an algorithm twice */
>>  			WARN_ON(1);
>> +			mutex_unlock(&rate_ctrl_mutex);
>>  			return -EALREADY;
>>  		}
>>  	}
> 
> Crud...there is a one-line fix in here that should have gone to Dave.
> 
> Jeff, (assuming Dave ACKs it) would you mind just taking it your
> way along with the other posted patches?  Since this is intended for
> 2.6.24, there should be no great maintenance hardship if it goes to
> Linus through your tree instead of Dave's.

Will do...

	Jeff
