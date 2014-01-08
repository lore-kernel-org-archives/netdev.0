From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v3 1/9] xen-netback: Introduce TX grant map definitions
Date: Wed, 8 Jan 2014 14:08:02 +0000
Message-ID: <52CD5BC2.5020803@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>	<1389139818-24458-2-git-send-email-zoltan.kiss@citrix.com> <20140107.202951.729942261773265015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140107.202951.729942261773265015.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/01/14 01:29, David Miller wrote:
>> +static inline int tx_dealloc_work_todo(struct xenvif *vif)
>
> Make this return bool.
Done, also in the last patch.

>> +		wait_event_interruptible(vif->dealloc_wq,
>> +					tx_dealloc_work_todo(vif) ||
>> +					 kthread_should_stop());
>
> Inconsistent indentation.  You should make the arguments line up at
> exactly the first column after the openning parenthesis of the function
> call.
Done, thanks.

Zoli
