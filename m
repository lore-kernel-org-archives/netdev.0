From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sun, 27 Feb 2005 20:16:22 -0800
Message-ID: <42229B16.6000006@candelatech.com>
References: <42208D83.80803@phekda.gotadsl.co.uk> <20050226181213.GA13230@electric-eye.fr.zoreil.com> <42224F76.9000602@phekda.gotadsl.co.uk> <200502272031.12291.jdmason@us.ibm.com> <422288EC.9010502@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Mason <jdmason@us.ibm.com>, Richard Dawe <rich@phekda.gotadsl.co.uk>,
        Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <422288EC.9010502@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Jon Mason wrote:
> 
>> I think I've found a (very hackish) way around the bad stats error. 
>> Tested on amd64, and "solves" the problem.
> 
> 
> Seems to me, we should instead find a way to avoid calling the stats 
> function if !netif_running()

Are the stats valid in the hardware if you start it, stop it, and then read them?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
