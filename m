From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH][netdev-next] net: hns: make guid hns_dsaf_acpi_dsm_guid
 static
Date: Tue, 13 Jun 2017 21:40:15 +0100
Message-ID: <5b3235bb-5058-82a6-d8be-76d805594cea@canonical.com>
References: <20170613130321.7797-1-colin.king@canonical.com>
 <20170613.135619.350474759117231721.davem@davemloft.net>
 <CAHp75VfQZN8bQj+7J-5tBE8gA5CmQL0xSdf3kajW8z92kCiBmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Yisen Zhuang <yisen.zhuang@huawei.com>, salil.mehta@huawei.com,
        huangdaode <huangdaode@hisilicon.com>,
        yankejian <yankejian@huawei.com>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        oulijun@huawei.com, netdev <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>,
        David Miller <davem@davemloft.net>,
        Christoph Hellwig <hch@lst.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VfQZN8bQj+7J-5tBE8gA5CmQL0xSdf3kajW8z92kCiBmQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/06/17 20:24, Andy Shevchenko wrote:
> On Tue, Jun 13, 2017 at 8:56 PM, David Miller <davem@davemloft.net> wrote:
>> From: Colin King <colin.king@canonical.com>
>> Date: Tue, 13 Jun 2017 14:03:21 +0100
>>
>>> From: Colin Ian King <colin.king@canonical.com>
>>>
>>> The guid hns_dsaf_acpi_dsm_guid does not need to be in global
>>> scope, so make it static.
>>>
>>> Cleans up sparse warning:
>>> "symbol 'hns_dsaf_acpi_dsm_guid' was not declared. Should it be static?"
>>>
>>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>>
>> That symbol doesn't even exist in th net-next tree.
> 
> It looks like the patch is done against UUID tree.
> Cc'ed Christoph.
> 
Sorry, I messed up on determining the original tree it came from in
linux-next when I looked at the output from get_maintainer.pl

Colin
