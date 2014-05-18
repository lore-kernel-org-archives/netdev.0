From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH] drivers: net: ethernet: mellanox: mlx4: let mlx4 depend
 on SMP
Date: Sun, 18 May 2014 18:08:16 +0800
Message-ID: <53788690.3010804@gmail.com>
References: <5376F2F8.3010603@gmail.com> <20140517.013655.349586284786993619.davem@davemloft.net> <CAJZOPZJN9YG2uAw0rSDkU0rQG=0FFDgSMnFDHpWS6hwZEqdwfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>, gxt@mprc.pku.edu.cn,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:41246 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaERKII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 06:08:08 -0400
In-Reply-To: <CAJZOPZJN9YG2uAw0rSDkU0rQG=0FFDgSMnFDHpWS6hwZEqdwfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2014 03:55 AM, Or Gerlitz wrote:
> On Sat, May 17, 2014 at 8:36 AM, David Miller <davem@davemloft.net> wrote:
>>
>> From: Chen Gang <gang.chen.5i5j@gmail.com>
>> Date: Sat, 17 May 2014 13:26:16 +0800
>>
>>> 'struct irq_affinity_notify' and the related functions are only defined
>>> when SMP enabled, so at present, mlx4 has to only run under SMP.
>>>
>>> The related error (allmodconfig under unicore32):
>>
>> Making the entire driver depend upon SMP is not the answer,
> 
> 
> Indeed, we would do that just for the relevant portion,
> 

Thank you for your work.

And next, when I meet the case like this again, instead of sending
patch, I shall send suggestion message to the related members/experts.


Thanks.
-- 
Chen Gang

Open, share and attitude like air, water and life which God blessed
