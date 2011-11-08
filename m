From: Daniil Stolnikov <danila.st@mail.ru>
Subject: Re: Add IPSec IP Range in Linux kernel
Date: Tue, 8 Nov 2011 22:24:11 +0800
Message-ID: <1247539123.20111108222411@mail.ru>
References: <92909814.20111108111036@mail.ru> <1320733465.21617.4.camel@ppwaskie-mobl2> <CACVxJT887ATwt97iw7mPEkH+KXgy1WbsP_aUB_X-8uLQ+6YsLQ@mail.gmail.com>
Reply-To: Daniil Stolnikov <danila.st@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	<linux-crypto@vger.kernel.org>,
	<linux-security-module@vger.kernel.org>, <davem@davemloft.net>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CACVxJT887ATwt97iw7mPEkH+KXgy1WbsP_aUB_X-8uLQ+6YsLQ@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Tue, Nov 8, 2011 at 8:24 AM, Peter P Waskiewicz Jr
> <peter.p.waskiewicz.jr@intel.com> wrote:
>> On Mon, 2011-11-07 at 19:10 -0800, Daniil Stolnikov wrote:
>>> Hello!
>>>
>>> Found that the stack IPSec in Linux does not support any IP range. Many people ask this question. The archives say strongswan said that their daemon supports a range, but the Linux IPSec stack supports only the subnets. I am writing to you to implement support for IP range in Linux. I think that a lot more people will appreciate this innovation.
>>
>> It'd be even better if you could write a patch for us to review.

> oh, come on!
> changing addr_match() is trivial for ipv4 and easy for ipv6. :-)


Is not entirely clear how this function works. It seems that it works again with the subnet bits and comparing the length of the prefix networks.

Probably you mean that you need to add back the comparison ranges? If so, what if we use zywall we do not know the format of the range.
Well, as I said, I badly oriented in the kernel code. I can tell kettle. A change in the function code certainly entail a change in at least the data types passed to the function.
