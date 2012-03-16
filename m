From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH net-next] ethtool: Added a field fw dump_state
Date: Fri, 16 Mar 2012 14:28:03 -0700
Message-ID: <CB88FD74.2A201%anirban.chakraborty@qlogic.com>
References: <1331932962.19406.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe002.messaging.microsoft.com ([213.199.154.140]:18740
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964969Ab2CPV2M convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2012 17:28:12 -0400
In-Reply-To: <1331932962.19406.23.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3/16/12 2:22 PM, "Eric Dumazet" <eric.dumazet@gmail.com> wrote:

>On Fri, 2012-03-16 at 14:10 -0700, Anirban Chakraborty wrote:
>> 
>> On 3/16/12 11:27 AM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:
>> 
>> >On Fri, 2012-03-16 at 10:58 -0700, Anirban Chakraborty wrote:
>> >> +
>> >>  struct ethtool_dump {
>> >>  	__u32	cmd;
>> >>  	__u32	version;
>> >>  	__u32	flag;
>> >>  	__u32	len;
>> >>  	__u8	data[0];
>> >> +	__u8	dump_state;
>> >
>> >Don't be ridiculous.
>> 
>> Yeah I know, especially when there is a flag field already present
>>there.
>> The only
>> reason, we considered for adding it is to keep the backward
>>compatibility
>> of scripts.
>> Right now, the flag field sets/gets the dump level of fw. If we use it
>>to
>> control the
>> dump state, then it would break the existing scripts, if there are any.
>> 
>
>You missed the point... data[0] must be the last element in the
>structure.
Yes, that was wrong struct. Sorry, I should have caught it earlier. We'll
resend it.

-Anirban
