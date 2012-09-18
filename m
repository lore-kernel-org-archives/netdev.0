From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Mon, 17 Sep 2012 22:55:43 -0700
Message-ID: <50580CDF.5050108@gmail.com>
References: <50578DE4.7080806@intel.com>  <1347915723.26523.179.camel@edumazet-glaptop> <5057E3F2.5090504@gmail.com>  <20120917.230300.653531213751776624.davem@davemloft.net>  <5057EA05.8020005@gmail.com> <1347947120.26523.207.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	tushar.n.dave@intel.com, john.r.fastabend@intel.com,
	mirqus@gmail.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:62538 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756089Ab2IRFzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 01:55:54 -0400
Received: by obbuo13 with SMTP id uo13so10004632obb.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 22:55:53 -0700 (PDT)
In-Reply-To: <1347947120.26523.207.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/17/2012 10:45 PM, Eric Dumazet wrote:
> On Mon, 2012-09-17 at 20:27 -0700, Alexander Duyck wrote:
>
>> It also just occurred to me that there might be some benefit in cache
>> aligning the max header size.  It seems like doing something like that
>> should reduce the overall memory footprint and would probably improve
>> performance.
> Given that most ACK packets are 66 bytes (14 ethernet + 20 IP + 32 TCP),
> I am not sure we need to make any tweak on alignment ?
I'm honestly not sure myself.  I will probably spend a few hours 
tomorrow tweaking a few things to test and see if there is any gain to 
be had there.  The only reason why it occurred to me is that it really 
isn't too far off from what we did back on the Rx side, except for there 
we were aligning at the start of the buffer and working our way up.

Thanks,

Alex
