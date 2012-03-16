From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH net-next] ethtool: Added a field fw dump_state
Date: Fri, 16 Mar 2012 15:37:42 -0700
Message-ID: <CB890E14.2A26C%anirban.chakraborty@qlogic.com>
References: <1331933824.2504.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:21551
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030808Ab2CPWhx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2012 18:37:53 -0400
In-Reply-To: <1331933824.2504.22.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3/16/12 2:37 PM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:

>On Fri, 2012-03-16 at 14:22 -0700, Eric Dumazet wrote:
>> On Fri, 2012-03-16 at 14:10 -0700, Anirban Chakraborty wrote:
>> > 
>> > On 3/16/12 11:27 AM, "Ben Hutchings" <bhutchings@solarflare.com>
>>wrote:
>> > 
>> > >On Fri, 2012-03-16 at 10:58 -0700, Anirban Chakraborty wrote:
>> > >> +
>> > >>  struct ethtool_dump {
>> > >>  	__u32	cmd;
>> > >>  	__u32	version;
>> > >>  	__u32	flag;
>> > >>  	__u32	len;
>> > >>  	__u8	data[0];
>> > >> +	__u8	dump_state;
>> > >
>> > >Don't be ridiculous.
>> > 
>> > Yeah I know, especially when there is a flag field already present
>>there.
>> > The only
>> > reason, we considered for adding it is to keep the backward
>>compatibility
>> > of scripts.
>> > Right now, the flag field sets/gets the dump level of fw. If we use
>>it to
>> > control the
>> > dump state, then it would break the existing scripts, if there are
>>any.
>> > 
>> 
>> You missed the point... data[0] must be the last element in the
>> structure.
>
>Right.  And len is documented as not used by the ETHTOOL_SET_DUMP
>command so we cannot say that when len == 1 then data[0] is this new
>flag.
>
>Just reserve some value of the flag to mean 'disable', say 0 or
>0xffffffff.  If you want this 'disable' value to be understood by all
>drivers and have ethtool support a keyword for it then also define a
>macro for the value in ethtool.h.

Thanks for your comments. We'll take care of it next submittal.

-Anirban
