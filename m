From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH RFC] Per route TCP options
Date: Wed, 21 Oct 2009 10:27:20 +0200
Message-ID: <4ADEC5E8.9060205@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com> <20091020221354.5a714323.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:39921 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbZJUI1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 04:27:20 -0400
In-Reply-To: <20091020221354.5a714323.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


Bill Fink wrote:

> On Tue, 20 Oct 2009, Gilad Ben-Yossef wrote:
>
>   
>> Turn the global sysctls allowing disabling of TCP SACK, DSCAK,
>> time stamp and window scale into per route entry feature options,
>> laying the ground to future removal of the relevant global sysctls.
>>
>> You really only want to disable SACK, DSACK, time stamp or window
>> scale if you've got a piece of broken networking equipment somewhere 
>> as a stop gap until you can bring a big enough hammer to deal with
>> the broken network equipment. It doesn't make sense to "punish" the
>> entire connections going through the machine to destinations not 
>> related to the broken equipment.
>>     
>
> For certain test situations, it is sometimes desirable to globally
> disable TCP timestamps.  Although I have not personally wanted to
> globally disable the other mentioned features, I can imagine test
> scenarios where it could be useful.  Admittedly it could also be
> accomplished with per route features, just not as conveniently,
> especially if there are a large number of interfaces and/or routes.
>
>   
I don't feel that strongly about it either way, just trying to hearken to
Linus "Linux is bloated" message by not fostering duplicate ways to do
the same thing... ;-)

If the consensus is to adopt the route features but leave the global
kill switches, I certainly have no problem with that.

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

