From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sat, 05 Mar 2005 13:53:36 +0000
Message-ID: <4229B9E0.2050205@phekda.gotadsl.co.uk>
References: <42208D83.80803@phekda.gotadsl.co.uk> <20050226181213.GA13230@electric-eye.fr.zoreil.com> <42224F76.9000602@phekda.gotadsl.co.uk> <200502272031.12291.jdmason@us.ibm.com> <422288EC.9010502@pobox.com> <42229B16.6000006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jon Mason <jdmason@us.ibm.com>,
        Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <42229B16.6000006@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Ben Greear wrote:
> Jeff Garzik wrote:
> 
>> Jon Mason wrote:
>>
>>> I think I've found a (very hackish) way around the bad stats error. 
>>> Tested on amd64, and "solves" the problem.
>>
>>
>>
>> Seems to me, we should instead find a way to avoid calling the stats 
>> function if !netif_running()
> 
> 
> Are the stats valid in the hardware if you start it, stop it, and then 
> read them?

They don't seem to be. I get the same kind of garbage before starting as 
  I do after I've started and stopped it.

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
