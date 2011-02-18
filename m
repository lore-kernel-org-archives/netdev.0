From: "Subhasish Ghosh" <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Fri, 18 Feb 2011 13:45:57 +0530
Message-ID: <184FA07B783D4F5FAAC09D5C11737A3F@subhasishg>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com>	<1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>	<20110211152026.GC373@e-circ.dyndns.org>
	<32A5399EB727427C98185089E5DBFA65@subhasishg>
	<4D5E2570.10108@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	"open list:CAN NETWORK DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	nsekhar-l0cyMroinI0@public.gmane.org, open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:CAN NETWORK DRIVERS" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	m-watkins-l0cyMroinI0@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D5E2570.10108-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

> On 02/18/2011 08:07 AM, Subhasish Ghosh wrote:
>> --------------------------------------------------
>> From: "Kurt Van Dijck" <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
>
> ...
>>>> + /* register interrupt handler */
>>>> + err = request_irq(priv->trx_irq, &omapl_rx_can_intr, IRQF_SHARED,
>>>> +   "pru_can_irq", ndev);
>>> you're doing a lot of work _in_ the irq handler. Maybe threaded irq?
>>>
>> SG -Ok, will do
>
> No, please use NAPI instead.

We are using h/w filters, so the number of interrupts coming into the 
processor are not hogging it.
I feel that we may not require an interrupt mitigation.

-Subhasish 
