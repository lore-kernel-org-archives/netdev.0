From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iproute2 -- add fwmarkmask
Date: Fri, 24 Feb 2006 05:59:33 +0100
Message-ID: <43FE92B5.4000606@trash.net>
References: <23395.1140452828@sandelman.ottawa.on.ca>
	<43F9F648.1060803@trash.net>
	<18992.1140723572@sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	shemminger@osdl.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <18992.1140723572@sandelman.ottawa.on.ca>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Michael Richardson wrote:
> 
> 
>>>>>>>"Patrick" == Patrick McHardy <kaber@trash.net> writes:
> 
>     Patrick> The normal way to display masks is with a "/". Also I think
>     Patrick> it shouldn't display the default mask to avoid breaking
>     Patrick> scripts that parse the output.
> 
>   I generally dislike the /VALUE, since I expect /PREFIX-LEN.
>   I agree that it shouldn't show if it is default.
> 
>     Patrick> ip should be able to parse its own output, and it would
>     Patrick> also look nicer if I could just say "fwmark
>     Patrick> 0x1/32". fwmarkmask is really an incredible ugly expression
>     Patrick> :)
> 
>   Sure. Is that a 32-bit long mask (0xfffffff), or is it a 0x00000020?
>   fwmark is not an address.
> 
>   Or would you like /32 to be a prefix-based mask, and &value and/or
> fwmarkmask to be a value? 

That was not the greatest example :) I think it should be a bitmask.
