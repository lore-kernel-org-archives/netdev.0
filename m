From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH 1/1] More ethtool support for sis900
Date: Sun, 6 Mar 2005 11:03:54 +0100
Message-ID: <ec1a7baeb975d07db2d0c4c757048309@libero.it>
References: <20050305134011.23638.68926@localhost.localdomain> <4229FA32.4000401@pobox.com> <02a49476862ae18433e5b80aafa616fd@libero.it> <20050306001546.GE25116@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
In-Reply-To: <20050306001546.GE25116@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On 06/mar/05, at 01:15, Francois Romieu wrote:

> Daniele Venzano <webvenza@libero.it> :
> [...]
>> I saw the locking, but I couldn't come up with a reason for it. Is it
>> needed because of kernel wide preemption ?
>
> Usually you do not want simultaneous accesses to the mii interface
> (link events, Tx timeout recovery or so).
>
> From a quick glance at the sis900 driver, I would expect the lock to
> protect against sis900_timer() (assuming you add a simple spinlock to
> it as well).
Yes, that makes sense. Will do.

Thanks.

--
Daniele Venzano
http://www.brownhat.org
