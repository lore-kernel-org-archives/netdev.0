From: David Brownell <david-b@pacbell.net>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Sun, 14 Sep 2003 19:50:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F652910.4090509@pacbell.net>
References: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, greearb@candelatech.com, jgarzik@pobox.com,
   scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ricardo C Gonzalez <ricardoz@us.ibm.com>,
   "David S. Miller" <davem@redhat.com>
In-Reply-To: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ricardo C Gonzalez wrote:
> 
> David Miller wrote:
> 
> 
>>Back to the main topic, maybe we should set dev->tx_queue_len to
>>1000 by default for all ethernet devices.
> 
> 
> 
> I definately agree with setting the dev->tx_queue_len to 1000 as a default
> for all ethernet adapters. All adapters will benefit from this change.

Except ones where CONFIG_EMBEDDED, maybe?  Not everyone wants
to spend that much memory, even when it's available...
