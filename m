From: Bryan Wu <bryan.wu@canonical.com>
Subject: Re: [PATCH 1/2] netdev/fec: fix performance impact from mdio poll
 operation
Date: Fri, 28 May 2010 13:23:30 +0800
Message-ID: <4BFF5352.8080104@canonical.com>
References: <1273199239-11057-1-git-send-email-bryan.wu@canonical.com>	<1273199239-11057-2-git-send-email-bryan.wu@canonical.com> <20100516.002818.133869940.davem@davemloft.net>
Reply-To: bryan.wu@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, gerg@uclinux.org,
	amit.kucheria@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100516.002818.133869940.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/16/2010 03:28 PM, David Miller wrote:
> From: Bryan Wu <bryan.wu@canonical.com>
> Date: Fri,  7 May 2010 10:27:18 +0800
> 
>> BugLink: http://bugs.launchpad.net/bugs/546649
>> BugLink: http://bugs.launchpad.net/bugs/457878
>>
>> After introducing phylib supporting, users experienced performace drop. That is
>> because of the mdio polling operation of phylib. Use msleep to replace the busy
>> waiting cpu_relax() and remove the warning message.
>>
>> Signed-off-by: Bryan Wu <bryan.wu@canonical.com>
>> Acked-by: Andy Whitcroft <apw@canonical.com>
> 
> As you've already been told, making these MDIO interfaces fail silently
> is not acceptable.
> 
> Please fix this bug properly and resubmit this patch series.
> 

So sorry for the delay. My board's broken for several weeks. After I got a new,
I will try to fix this and resubmit this patch.

Thanks
-- 
Bryan Wu <bryan.wu@canonical.com>
Kernel Developer    +86.138-1617-6545 Mobile
Ubuntu Kernel Team | Hardware Enablement Team
Canonical Ltd.      www.canonical.com
Ubuntu - Linux for human beings | www.ubuntu.com
