From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BCM5704 performance questions.
Date: Thu, 09 Jun 2005 16:56:16 -0700
Message-ID: <1118361376.5838.20.camel@rh4>
References: <42A8E0FE.3020708@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <42A8E0FE.3020708@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-06-09 at 17:38 -0700, Ben Greear wrote:

> 
> *  Is the BCM5704 chipset/driver really that much slower?
> 

Unfortunately, the 5704 requires the "ONE_DMA" workaround which will
limit throughput in a PCIX 100/133 bus. If you comment out the line that
sets the DMA_RWCTRL_ONE_DMA flag in tg3.c, you should see improved
performance. However, you may run into some DMA issues on certain
systems.

> *  Is there some information on tuning the tg3 somewhere?
>     (I didn't see a Documentation/networking/tg3.txt file, for instance)
> 
> *  Is there a way to verify the bus speed that the NIC is running at?
>     (ethtool -d ethX gives lots of meaningless (to me) hex)
> 

tg3 probing string for each device will tell you the bus type, width,
and speed.
