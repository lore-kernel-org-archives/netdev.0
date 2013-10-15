From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH RFC 5/5] net: macb: Adjust tx_clk when link speed changes
Date: Tue, 15 Oct 2013 09:58:09 +0200
Message-ID: <dd225b7c-ee2a-4747-9a50-55b77a114376@DB9EHSMHS006.ehs.local>
References: <1381795140-10792-1-git-send-email-soren.brinkmann@xilinx.com> <1381795140-10792-6-git-send-email-soren.brinkmann@xilinx.com> <525CF4AD.1070304@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Soren Brinkmann <soren.brinkmann@xilinx.com>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <525CF4AD.1070304@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/2013 09:54 AM, Nicolas Ferre wrote:
> On 15/10/2013 01:59, Soren Brinkmann :
>> Adjust the ethernet clock according to the negotiated link speed.
>>
>> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> 
> I will need more time to study this one.
> 
> Moreover, I will have to add the "tx_clk" to every user of this driver before switchin to the addition of this clock.

As I am reading this patch, Soren just protected this
case that if this clk is not specified then it is not used.

But anyway feel free to take more time to study it.

If there is device-tree binding then it should be extend
by this optional value.

Thanks,
Michal
