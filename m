From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyperv: Add processing of MTU reduced by the host
Date: Wed, 12 Nov 2014 15:04:23 -0500 (EST)
Message-ID: <20141112.150423.1660890641226643870.davem@davemloft.net>
References: <1415748472-27463-1-git-send-email-haiyangz@microsoft.com>
 <20141112.144640.703336197189868183.davem@davemloft.net>
 <ecc2fd8e646147fabb30d3120c889431@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <ecc2fd8e646147fabb30d3120c889431@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Wed, 12 Nov 2014 20:02:11 +0000

> The Hyper-V host doesn't support MTU below 1500. If we try setting MTU to a 
> value < 1500, the host will use 1500 automatically and return 1500 in the 
> RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE query and guest will also use it. That's 
> why I set the lower limit to ETH_DATA_LEN.
> 
> Are you suggesting that we keep the 68 as the lower limit, and let the host 
> auto-reset it to 1500 when we trying to set an MTU < 1500?

Then you need to add a comment, because without any information or
context that change looks wrong.
