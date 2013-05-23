From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] bridge: netfilter: using strlcpy() instead of strncpy()
Date: Thu, 23 May 2013 18:57:05 +0800
Message-ID: <519DF601.1010400@asianux.com>
References: <5195E53A.4060406@asianux.com> <20130523105600.GA22553@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bart.de.schuymer@pandora.be, kaber@trash.net,
	stephen@networkplumber.org, David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130523105600.GA22553@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2013 06:56 PM, Pablo Neira Ayuso wrote:
> On Fri, May 17, 2013 at 04:07:22PM +0800, Chen Gang wrote:
>> > 
>> > 'name' has already set all zero when it is defined, so not need let
>> > strncpy() to pad it again.
>> > 
>> > 'name' is a string, better always let is NUL terminated, so use
>> > strlcpy() instead of strncpy().
> Applied, thanks.
> 
> 

Thank you too.

-- 
Chen Gang

Asianux Corporation
