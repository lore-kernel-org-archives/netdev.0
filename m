From: Henrik Petander <lpetande@tml.hut.fi>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Tue, 10 Jun 2003 18:25:18 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE5F85E.9080006@tml.hut.fi>
References: <20030606223057.41ac1c9d.nakam@linux-ipv6.org>	<Pine.GSO.4.44.0306091140470.25126-100000@morphine.tml.hut.fi> <20030609203659.089b241b.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Henrik Petander <lpetande@morphine.tml.hut.fi>,
   YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, vnuorval@tcs.hut.fi,
   davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   ajtuomin@morphine.tml.hut.fi, jagana@us.ibm.com, kumarkr@us.ibm.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <20030609203659.089b241b.nakam@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Masahide NAKAMURA wrote:
> On Mon, 9 Jun 2003 12:06:35 +0300 (EEST)
> Henrik Petander <lpetande@morphine.tml.hut.fi> wrote:
> 
> 
>>On Fri, 6 Jun 2003, Masahide NAKAMURA wrote:
>>
>>>We don't think we have to change the logic handling policy with
>>>the reason because we can treat MIPv6 policy just like IPsec.
>>>
>>>When we want to apply both MIPv6 and IPsec to the same target,
>>>we need one policy that has two or more of templates(e.g. one is
>>>MIPv6's template and the other is IPsec's).
>>
>>Does this also mean that the IPSec and MIPv6 policies and SAs need to be
>>configured at the same time or is it possible to add templates to an
>>existing policy?
> 
> 
> Currently no interface to add templates directly to it.

Then the policies for mipv6 would need to be specified at the same time 
as the ipsec policies. This is not a problem as long as the policies are 
  loaded at start up. However, this could lead to problems with 
applications which specify their own policies, e.g. racoon.

Henrik
