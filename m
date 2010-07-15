From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: several messages
Date: Thu, 15 Jul 2010 12:17:46 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007151216170.19772@obet.zrqbmnf.qr>
References: <20100711150623.GA7420@redhat.com> <20100711151453.GA7563@redhat.com> <4C3ED764.3060301@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	herbert@gondor.hengli.com.au
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C3ED764.3060301@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2010-07-15 11:36, Patrick McHardy wrote:
>> +struct xt_CHECKSUM_info {
>> +	u_int8_t operation;	/* bitset of operations */
>
>Please use __u8 in public header files.
>
>> +#include <linux/in.h>
>
>Do you really need in.h?
>
>> + * $Id$
>
>Please no CVS IDs.
>
>> +	switch (c) {
>> +	case 'F':
>> +		if (*flags)
>> +			xtables_error(PARAMETER_PROBLEM,
>> +			        "CHECKSUM target: Only use --checksum-fill ONCE!");
>
>There is a helper function called xtables_param_act for checking double
>arguments and printing a standarized error message.

I took care of these for Xt-a.
