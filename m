From: "Du, Fan" <fan.du@intel.com>
Subject: Re: [PATCH net-next] net: hns: optimize XGE capability by reducing
 cpu usage
Date: Tue, 08 Dec 2015 14:30:57 +0800
Message-ID: <56667921.2010006@intel.com>
References: <1449300749-50275-1-git-send-email-yankejian@huawei.com> <56654A31.4080607@intel.com> <56667729.1080701@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: haifeng.wei@huawei.com, yisen.zhuang@huawei.com,
	linuxarm@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Yankejian (Hackim Yim)" <yankejian@huawei.com>,
	davem@davemloft.net, lisheng011@huawei.com, lipeng321@huawei.com,
	salil.mehta@huawei.com, huangdaode@hisilicon.com,
	xuwei5@hisilicon.com, liguozhu@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56667729.1080701@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/12/8 14:22, Yankejian (Hackim Yim) wrote:
>
> On 2015/12/7 16:58, Du, Fan wrote:
>> >
>> >
>> >On 2015/12/5 15:32, yankejian wrote:
>>> >>here is the patch raising the performance of XGE by:
>>> >>1)changes the way page management method for enet momery, and
>>> >>2)reduces the count of rmb, and
>>> >>3)adds Memory prefetching
>> >
>> >Any numbers on how much it boost performance?
>> >
> it is almost the same as 82599.

I mean how much it improves performance *BEFORE* and *AFTER* this patch
for Huawei XGE chip, because the commit log states it "raising the 
performance",
but did give numbers of the testing.
