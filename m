From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: Re: [PATCH 3.3.0 1/3] net:phy:bcm63xx: remove unnecessary code
Date: Mon, 02 Apr 2012 17:51:38 +0100
Message-ID: <4F79D91A.2030403@st.com>
References: <1333383895-23889-1-git-send-email-srinivas.kandagatla@st.com> <1333384945.15422.14.camel@joe2Laptop>
Reply-To: srinivas.kandagatla@st.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:52373 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752154Ab2DBQx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 12:53:29 -0400
In-Reply-To: <1333384945.15422.14.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/12 17:42, Joe Perches wrote:
> On Mon, 2012-04-02 at 17:24 +0100, Srinivas KANDAGATLA wrote:
>> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>>
>> Compile tested.
>> remove unnecessary code that matches this coccinelle pattern
>>
>> 	ret = phy_write(x, y , z)
>> 	if (ret < 0)
>> 		return ret;
>> 	return 0;
>>
>> As phy_write returns error code, we dont need to do not need extra check
>> before returning.
>
> Do these really make any functional difference?
No it does not make any functional difference.
> Doesn't the compiler generate the same output?
>
I think it will not generate same output.
> Many times, there's a code pattern that precedes these
> calls has a similar pattern and changing the pattern
> for the last call in a sequence can be jarring to a
> reader and changing the pattern can sometimes introduce
> errors as well.
There is a purpose(error handling) of having similar pattern for the
code above last call, However there is no value for doing an additional
check before returning.
If we look at other phy files(ex:boardcom.c..), we can see they do
something similar to what the patch does in config_init.

>
>
