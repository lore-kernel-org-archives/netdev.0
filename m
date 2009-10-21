From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH RFC] Allow to turn off TCP window scale opt per route
Date: Wed, 21 Oct 2009 10:18:54 +0200
Message-ID: <4ADEC3EE.2070301@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>	<1256052161-14156-2-git-send-email-gilad@codefidence.com>	<1256052161-14156-3-git-send-email-gilad@codefidence.com>	<1256052161-14156-4-git-send-email-gilad@codefidence.com>	<1256052161-14156-5-git-send-email-gilad@codefidence.com>	<1256052161-14156-6-git-send-email-gilad@codefidence.com>	<1256052161-14156-7-git-send-email-gilad@codefidence.com> <20091021104024.32adab23@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:59833 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbZJUISz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 04:18:55 -0400
In-Reply-To: <20091021104024.32adab23@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

> On Tue, 20 Oct 2009 17:22:39 +0200
> Gilad Ben-Yossef <gilad@codefidence.com> wrote:
>
>   
>> Add and use no window scale bit in the features field.
>>
>> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
>> Sigend-off-by: Ori Finkelman <ori@comsleep.com>
>> Sigend-off-by: Yony Amit <yony@comsleep.com>
>>     
>
> The same effect can by just using window limit on route
>   
Actually, not exactly. There is a subtle but important difference 
between "I support window scaling, but choose a scale of 0", which is 
what your suggestion will imply and "I don't support window scaling at 
all", which is what the suggested feature field does.

To make things more complicated, until the previous patch I sent, when 
Linux would choose a window scale of zero for any reason, it would also 
wrongfully report it does not support window scaling at all to the other 
side, with some subtle bug caused by it, but this is no longer the 
behavior and I believe rightly so.

Thanks,
Gilad

-- 
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
Fax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxology.net

	"Sorry cannot parse this, its too long to be true  :)"
	  -- Eric Dumazet on netdev mailing list

