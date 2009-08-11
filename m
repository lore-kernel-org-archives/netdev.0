From: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Subject: Re: [Bugme-new] [Bug 13954] New: Oops in rtnetlink code when creating
 can device
Date: Tue, 11 Aug 2009 11:36:52 +0200
Message-ID: <4A813BB4.6070109@volkswagen.de>
References: <bug-13954-10286@http.bugzilla.kernel.org/> <20090810215436.0bf47297.akpm@linux-foundation.org> <4A812354.8090704@volkswagen.de> <4A812A3C.10207@trash.net> <4A813963.10407@volkswagen.de> <4A813AEF.7000002@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Wolfgang Grandegger <wg@grandegger.com>, dbaryshkov@gmail.com,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	"Thuermann, Urs, Dr. (K-EFFI/I)" <urs.thuermann@volkswagen.de>,
	Lothar Wassmann <LW@KARO-electronics.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxout1.volkswagen.de ([194.114.62.41]:2282 "EHLO
	mxout1.volkswagen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbZHKMpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 08:45:20 -0400
In-Reply-To: <4A813AEF.7000002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
>
>>> You could add a ->newlink() function that unconditionally returns
>>> an error.
>>>
>>>   
>>>       
>> Yes, that fixed it.
>>
>> I created a can_newlink() function just returning -EINVAL ...
>>
>> I'll cook a patch and send it on netdev (when it gets online again).
>>     
>
> I'd suggest to use EOPNOTSUPP for consistency.
>
>   

Ok. Will do so.

Thanks!

Oliver

