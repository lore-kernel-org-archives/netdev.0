From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: build failure
Date: Thu, 05 Aug 2010 09:48:01 -0700
Message-ID: <4C5AEB41.9050903@intel.com>
References: <4C5A4CF4.4070203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: divya <dipraksh@linux.vnet.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4C5A4CF4.4070203@linux.vnet.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divya wrote:
> Yestersday's linux-next(2.6.35_next_20100802) build fails with the following error on both system p and x.
> 
> 
>    drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_select_queue':
>    drivers/net/ixgbe/ixgbe_main.c:6159: error: 'struct ixgbe_fcoe' has no member named 'up'
>    drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_xmit_frame':
>    drivers/net/ixgbe/ixgbe_main.c:6221: error: 'struct ixgbe_fcoe' has no member named 'up'
>    make[3]: *** [drivers/net/ixgbe/ixgbe_main.o] Error 1
>    make[2]: *** [drivers/net/ixgbe] Error 2
>    make[2]: *** Waiting for unfinished jobs....
>    make[1]: *** [drivers/net] Error 2
>    make: *** [drivers] Error 2
> 
> Thanks
> Divya
> 
> 

Hi Divya,

Jeff should have a fix for this in his queue already.  This is caused by 
building with CONFIG_FCOE and without CONFIG_IXGBE_DCB.

Thanks,
John.
