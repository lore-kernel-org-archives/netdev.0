From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 7/8] tools lib bpf: fix maps resolution
Date: Mon, 17 Oct 2016 10:23:27 +0800
Message-ID: <5804361F.9050108@huawei.com>
References: <20161016211834.11732-1-eric@regit.org>
 <20161016211834.11732-8-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <ast@fb.com>
To: Eric Leblond <eric@regit.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161016211834.11732-8-eric@regit.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/10/17 5:18, Eric Leblond wrote:
> It is not correct to assimilate the elf data of the maps section
> to an array of map definition. In fact the sizes differ. The
> offset provided in the symbol section has to be used instead.
>
> This patch fixes a bug causing a elf with two maps not to load
> correctly.

Could you please give an example so we can understand why
section 'maps' is not an array?

Thank you.
