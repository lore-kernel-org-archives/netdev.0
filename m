From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v2 4/8] Add the no SACK route option feature
Date: Sun, 25 Oct 2009 10:44:05 +0200
Message-ID: <4AE40FD5.8070108@codefidence.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-5-git-send-email-gilad@codefidence.com> <4ADF5F77.6050407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:35014 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbZJYIoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 04:44:03 -0400
In-Reply-To: <4ADF5F77.6050407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:

> Gilad Ben-Yossef wrote:
>> Implement querying and acting upon the no sack bit in the features
>> field.
>>
>>  #define RTAX_FEATURE_ECN    0x00000001
>> -#define RTAX_FEATURE_SACK    0x00000002
>> +#define RTAX_FEATURE_NO_SACK    0x00000002
>>  #define RTAX_FEATURE_TIMESTAMP    0x00000004
>>  #define RTAX_FEATURE_ALLFRAG    0x00000008
>>  
> I just realized that unlike NO_DSACK, this change assumes removing the
> sysctl and defaulting on.
Once again, no it does not do no such thing. The sysctl and semantics 
stays here just the same.

The RTAX_FEATURE_SACK is not sued AFAIK in current code at all.

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

