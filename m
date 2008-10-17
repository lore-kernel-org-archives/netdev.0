From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.27 seems to break something with DSL
Date: Fri, 17 Oct 2008 08:03:17 +0000
Message-ID: <20081017080317.GA5596@ff.dom.local>
References: <20081011140240.GA5985@joi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcin Slusarz <marcin.slusarz@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Philip Stark <heller.barde@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:44235 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbYJQIDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 04:03:23 -0400
Received: by ug-out-1314.google.com with SMTP id k3so2096729ugf.37
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2008 01:03:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081011140240.GA5985@joi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-10-2008 16:02, Marcin Slusarz wrote:
> On Sat, Oct 11, 2008 at 02:53:16PM +0200, Philip Stark wrote:
>> Hi,
>>
>> I'm sorry, I didn't lurk before making my first posting to this list,
>> but it seemed to me that this might be an important problem/bug (if it
>> is one).
>>
>> first off, my network infrastructure:
>>
>> "internet" --(magic*)-- DSL Modem --(DHCP)-- Router --(DHCP)-- Computer
>> * PPPsomething i guess...
>>
>> My observations so far:
>>
>> with kernel =< 2.6.26 i can connect to the rest of the world perfectly
>> (ping works and i can browse "the internet")
>>
>> now with kernel 2.6.27, i.e with all the release candidates and also
>> with the final version from yesterday i can ping anything just fine,
>> but i can't browse. that is when i 'wget kernel.org' it resolves the
>> address into the correct IP and then goes on to 'connecting' just to
>> grind to a complete halt. after some time of course it times out.
>> it seems to  be related to the packet  size because ping only seems to
>> work because it uses small packets. if i increase the ping size up to
>> 1000 bytes, it fails as well. (while it does work on 2.6.26)
>>
>> oh and it is the same problem on the wireless and the wired interface.
>> on 2 different laptops and on my desktop (which have different
>> networking chips, two intel and one realtek)
>>
>> best Regards
>> Philip Stark
>>
>> PS: if i horribly misposted, please slap me across the face and ignore me :)

Hi,

Could you send tcpdump -v on some interface as near "internet" as
possible while doing this 1000 bytes ping? (Btw. what is this router?)
It would be nice to have this both for 2.6.26 and 2.6.27.

Thanks,
Jarek P.
