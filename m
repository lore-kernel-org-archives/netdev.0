From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/02] add mask options to fwmark masking code
Date: Fri, 24 Feb 2006 05:58:42 +0100
Message-ID: <43FE9282.7010002@trash.net>
References: <23140.1140452813@sandelman.ottawa.on.ca>
	<43F9F4E7.5000708@trash.net>
	<16464.1140723418@sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netfilter-devel <netfilter-devel@lists.netfilter.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <16464.1140723418@sandelman.ottawa.on.ca>
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
>     >> #define RTA_FWMARK RTA_PROTOINFO +#define RTA_FWMARK_MASK
>     >> RTA_CACHEINFO
> 
>     Patrick> Please introduce a new attribute for this instead of
>     Patrick> overloading RTA_CACHEINFO.
> 
>   I would be happy to do that.
>   Should I also un-overload FWMARK, with backwards compatibility?

No, that one is fine since it doesn't already have a different meaning.
