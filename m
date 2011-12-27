From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: calxeda xgmac ethernet driver add missing
 HAS_IOMEM dependency
Date: Tue, 27 Dec 2011 13:01:56 -0500 (EST)
Message-ID: <20111227.130156.1047123326718924884.davem@davemloft.net>
References: <1324994825-4197-1-git-send-email-heiko.carstens@de.ibm.com>
	<4EF9D327.3070808@calxeda.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rob.herring@calxeda.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EF9D327.3070808@calxeda.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>
Date: Tue, 27 Dec 2011 08:16:07 -0600

> On 12/27/2011 08:07 AM, Heiko Carstens wrote:
>> Fix allyesconfig build on architectures without IOMEM:
>> 
>> drivers/net/ethernet/calxeda/xgmac.c:1800:2:
>>   error: implicit declaration of function 'iounmap' [-Werror=implicit-function-declaration]
>> 
>> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
>> Cc: Rob Herring <rob.herring@calxeda.com>
> 
> Thanks.
> 
> Acked-by: Rob Herring <rob.herring@calxeda.com>

Applied, thanks.
