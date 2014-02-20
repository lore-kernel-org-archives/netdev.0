From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/8] cxgb4: Add support to recognize 40G links
Date: Thu, 20 Feb 2014 11:16:26 -0800
Message-ID: <5306548A.2090406@chelsio.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com> <1392726375-32001-2-git-send-email-hariprasad@chelsio.com> <53051E48.9050901@opengridcomputing.com> <53064459.3030106@chelsio.com> <CAGVrzcbb-7sQqHyf8SS8-mUyD+LM==Z6r3Zy1rFQ72WHFveMcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, dm@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:36105
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752541AbaBTTQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 14:16:32 -0500
In-Reply-To: <CAGVrzcbb-7sQqHyf8SS8-mUyD+LM==Z6r3Zy1rFQ72WHFveMcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 02/20/14 11:00, Florian Fainelli wrote:
> 2014-02-20 10:07 GMT-08:00 Casey Leedom <leedom@chelsio.com>:
>> On 02/19/14 13:12, Steve Wise wrote:
>>>
>>> You probably should add SPEED_40000 to include/uapi/linux/ethtool.h as
>>> part of this series.
>>
>>    I'm ~pretty sure~ that the "word on the street" was that the community
>> wanted to get away from the SPEED_XXX symbols since they simply represented
>> the values XXX.  Thus they didn't offer any real symbolic isolation from
>> weird constants, etc.  I believe that the old SPEED_XXX values were left in
>> place in order to avoid making tons of changes everywhere ...
> Not quite sure where and when you heard that, it seems a little
> disturbing to add a comment in this patch saying "this I how I should
> fix things" and not do them, especially when this is a one-liner.
> Having a well defined constant is easier to grep than having the
> open-coded 40000 constant which will lead to false positives
> throughout the tree.

   Like I said, it was a vague memory at best from over a year ago. I 
seem to remember someone on our team trying to push SPEED_40000 into the 
kernel and getting rebuffed.  Perhaps I didn't have enough coffee that day.

   In any case, I personally like the idea of SPEED_40000 for exactly 
the reason you offer: I can search for it meaningfully.  So If my vague 
memory is wrong, yeay!

Casey

> --
> Florian
