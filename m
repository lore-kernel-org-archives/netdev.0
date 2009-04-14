From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]ipv6:remove useless check
Date: Tue, 14 Apr 2009 02:22:27 -0700 (PDT)
Message-ID: <20090414.022227.88248944.davem@davemloft.net>
References: <49E3EC04.5000105@cn.fujitsu.com>
	<49E4039C.5080908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, netdev@vger.kernel.org, brian.haley@hp.com
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57209
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750746AbZDNJWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 05:22:36 -0400
In-Reply-To: <49E4039C.5080908@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Tue, 14 Apr 2009 11:31:40 +0800

> Yang Hongyang said:
>> After switch (rthdr->type) {...},the check below is completely useless.Because:
>> if the type is 2,then hdrlen must be 2 and segments_left must be 1,clearly the
>> check is redundant;if the type is not 2,then goto sticky_done,the check is useless
>> too.
>> 
> 
> Add CC  Brian Haley.
> 
> The check is defined only for Type 0 Routing header in section 4.4 of RFC2460: 
> 
>    Hdr Ext Len          8-bit unsigned integer.  Length of the Routing
>                         header in 8-octet units, not including the first
>                         8 octets.  For the Type 0 Routing header, Hdr
>                         Ext Len is equal to two times the number of
>                         addresses in the header.
> 
> Now, Type 0 Routing header has been removed, the check is redundant.
> 
> Reviewed-by: Shan Wei <shanwei@cn.fujitsu.com>
> 
>> Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>

Applied, thanks everyone.
