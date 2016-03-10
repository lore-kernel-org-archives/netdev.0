From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [patch net 1/2] net: hns: fix return value of the function about
 rss
Date: Thu, 10 Mar 2016 20:04:18 +0800
Message-ID: <56E162C2.6070709@huawei.com>
References: <1457576189-22924-1-git-send-email-yankejian@huawei.com>
 <1457576189-22924-2-git-send-email-yankejian@huawei.com>
 <1457597509.1347.49.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, andrew@lunn.ch, salil.mehta@huawei.com,
 liguozhu@huawei.com, haifeng.wei@huawei.com, arnd@arndb.de,
 lisheng011@huawei.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linuxarm@huawei.com, chenny.xu@huawei.com, huangdaode@hisilicon.com,
 fengguang.wu@intel.com, yisen.zhuang@huawei.com,
 linux-arm-kernel@lists.infradead.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1457597509.1347.49.camel@linux.intel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org



On 2016/3/10 16:11, Andy Shevchenko wrote:
> On Thu, 2016-03-10 at 10:16 +0800, Kejian Yan wrote:
>> Both .get_rxfh and .get_rxfh are always return 0, it should return
>> result
>> from hardware when getting or setting rss. And the rss function
>> should
>> return the correct data type.
>>
> @@ -1213,7 +1213,7 @@ hns_get_rss(struct net_device *netdev, u32
>> *indir, u8 *key, u8 *hfunc)
>>  
>>
>>  	ret = ops->get_rss(priv->ae_handle, indir, key, hfunc);
>>  
>> -	return 0;
>> +	return ret;
> All three can be one line.

ok, thanks!

>> @@ -1241,7 +1241,7 @@ hns_set_rss(struct net_device *netdev, const
>> u32 *indir, const u8 *key,
>>  
>>  	ret = ops->set_rss(priv->ae_handle, indir, key, hfunc);
>>  
>> -	return 0;
>> +	return ret;
> Ditto.
>
ok, thanks!
