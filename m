From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] af_iucv: wrong mapping of sent and confirmed skbs
Date: Mon, 12 May 2014 17:56:08 +0400
Message-ID: <5370D2F8.60300@cogentembedded.com>
References: <20140512110139.GA38070@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	stable@vger.kernel.org
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>, davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140512110139.GA38070@tuxmaker.boeblingen.de.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/12/2014 03:01 PM, Frank Blaschka wrote:

> From: Ursula Braun <ursula.braun@de.ibm.com>

> When sending data through IUCV a MESSAGE COMPLETE interrupt
> signals that sent data memory can be freed or reused again.
> With commit f9c41a62bba3f3f7ef3541b2a025e3371bcbba97 the

    Please also specify that commit's summary line in parens.

> MESSAGE COMPLETE callback iucv_callback_txdone() identifies
> the wrong skb as being confirmed, which leads to data corruption.
> This patch fixes the skb mapping logic in iucv_callback_txdone().

> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> Cc: <stable@vger.kernel.org>

WBR, Sergei
