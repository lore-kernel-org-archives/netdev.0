From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] bridge: netfilter: using strlcpy() instead of strncpy()
Date: Mon, 20 May 2013 09:04:14 +0800
Message-ID: <5199768E.4060706@asianux.com>
References: <5195E53A.4060406@asianux.com> <51992B6F.70309@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bart.de.schuymer@pandora.be, pablo@netfilter.org, kaber@trash.net,
	stephen@networkplumber.org, David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev <netdev@vger.kernel.org>
To: Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <51992B6F.70309@pandora.be>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/20/2013 03:43 AM, Bart De Schuymer wrote:
> Op 17/05/2013 10:07, Chen Gang schreef:
>>
>> 'name' has already set all zero when it is defined, so not need let
>> strncpy() to pad it again.
>>
>> 'name' is a string, better always let is NUL terminated, so use
>> strlcpy() instead of strncpy().
>>
>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> Acked-by: Bart De Schuymer <bdschuym@pandora.be>

Thanks.

-- 
Chen Gang

Asianux Corporation
