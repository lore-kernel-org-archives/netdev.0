From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Mon, 17 Sep 2012 20:27:01 -0700
Message-ID: <5057EA05.8020005@gmail.com>
References: <50578DE4.7080806@intel.com> <1347915723.26523.179.camel@edumazet-glaptop> <5057E3F2.5090504@gmail.com> <20120917.230300.653531213751776624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexander.h.duyck@intel.com,
	tushar.n.dave@intel.com, john.r.fastabend@intel.com,
	mirqus@gmail.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:45912 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932283Ab2IRD1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 23:27:10 -0400
Received: by obbuo13 with SMTP id uo13so9896988obb.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 20:27:09 -0700 (PDT)
In-Reply-To: <20120917.230300.653531213751776624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/17/2012 8:03 PM, David Miller wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Mon, 17 Sep 2012 20:01:06 -0700
>
>> Since MAX_TCP_HEADER starts at 160 the likelihood of it not getting
>> at least 16 bytes of padding is pretty low.
> I know it's not on many people's radar, but with SLOB it will happen
> a lot probably.

That is true.  I hadn't thought about anything other than SLAB/SLUB.

It also just occurred to me that there might be some benefit in cache 
aligning the max header size.  It seems like doing something like that 
should reduce the overall memory footprint and would probably improve 
performance.

Thanks,

Alex
