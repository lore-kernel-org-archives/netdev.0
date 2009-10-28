From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v3 4/7] Add the no SACK route option feature
Date: Wed, 28 Oct 2009 12:18:30 +0200
Message-ID: <4AE81A76.5080600@codefidence.com>
References: <1256544393-12450-1-git-send-email-gilad@codefidence.com> <1256544393-12450-5-git-send-email-gilad@codefidence.com> <4AE5D089.2050606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:57814 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbZJ1KSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 06:18:33 -0400
In-Reply-To: <4AE5D089.2050606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:

> Gilad Ben-Yossef wrote:
>> Implement querying and acting upon the no sack bit in the features
>> field.
>>
>> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
>> Sigend-off-by: Ori Finkelman <ori@comsleep.com>
>> Sigend-off-by: Yony Amit <yony@comsleep.com>
>>
> Please explain how this code turns SACK on when it is off globally?
>
> As both Eric and I asked?
It doesn't. Please see my discussion with Eric for the why.

In short, doing so introduce a very subtle change to what the existing 
interface do today, which will break
backwards compatibility by changing the meaning of writing zero to the 
relevant sysctl. I don't want to be hunt down by angry sys admins :-)

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

	"The biggest risk you can take it is to take no risk."
		-- Mark Zuckerberg and probably others

