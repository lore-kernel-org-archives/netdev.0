From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] phylib: Fix Freescale TBI PHY detection
Date: Wed, 14 Jan 2009 12:20:35 -0600
Message-ID: <4DDB8462-ACB6-494A-A1CB-4F56668A4EE1__45407.8984600075$1231957490$gmane$org@freescale.com>
References: <20090113160513.GA22083@oksana.dev.rtsoft.ru>
	<20090114150332.GA839@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Giulio Benetti <giulio.benetti@micronovasrl.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20090114150332.GA839@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Jan 14, 2009, at 9:03 AM, Anton Vorontsov wrote:
>>
>> There is one thing I don't actually understand though...
>>
>> Andy, were you testing the TBI support on a hardware where PHY ID
>> != 0x0 or maybe your TBI PHY support patch (commit b31a1d8b41513b,
>> dated Tue Dec 16 15:29:15 2008) was based on a bit outdated kernel
>> version? Because according to the git timestamps, the TBI support
>> was not working since the submission.
>>
>> Just in case, the hardware I'm seeing the PHY ID == 0x0 is
>> MPC8378E-MDS.
>
> I think I got it. Probably the TBI support patch was based on the
> powerpc.git next, and the commit that broke the TBI support
> was in the net-next-2.6 tree.
>
> That explains why nobody noticed the issue.


Yeah, I dropped the ball.  I saw the patch go in, thought that might  
break something, but I didn't find time to look into it.  Thanks for  
finding and reverting this bug.

Acked-by: Andy Fleming <afleming@freescale.com>
