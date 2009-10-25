From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v2 5/8] Allow disabling TCP timestamp options per route
Date: Sun, 25 Oct 2009 10:43:13 +0200
Message-ID: <4AE40FA1.5040309@codefidence.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-6-git-send-email-gilad@codefidence.com> <4ADF5F5A.5090403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:35005 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbZJYInL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 04:43:11 -0400
In-Reply-To: <4ADF5F5A.5090403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


William Allen Simpson wrote:

>
>> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
>> index 9c802a6..2ab8c75 100644
>> --- a/include/linux/rtnetlink.h
>> +++ b/include/linux/rtnetlink.h
>> @@ -378,7 +378,7 @@ enum
>>  
>>  #define RTAX_FEATURE_ECN    0x00000001
>>  #define RTAX_FEATURE_NO_SACK    0x00000002
>> -#define RTAX_FEATURE_TIMESTAMP    0x00000004
>> +#define RTAX_FEATURE_NO_TSTAMP    0x00000004
>>  #define RTAX_FEATURE_ALLFRAG    0x00000008
>>  
> I just realized that unlike NO_WSCALE, this change assumes removing the
> sysctl and defaulting on.
No, it doesn't. This patch does not change the sysctl behavior in any 
way. The RTAX_FEATURE_TIMESTAMP define is a currently a dead code not 
used anywhere AFAIK.

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

