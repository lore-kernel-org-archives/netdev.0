From: Ben Greear <greearb@candelatech.com>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 08:43:17 -0700
Message-ID: <46F3E695.7010604@candelatech.com>
References: <1190359905.3551.28.camel@magi.nadr>	 <1190375946.4261.42.camel@localhost>  <1190379015.3551.57.camel@magi.nadr>	 <1190381841.4231.10.camel@localhost> <1190382366.4231.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Emil Micek <emil.micek@tkrjasek.cz>,
	"auke-jan.h.kok@intel.com" <auke-jan.h.kok@intel.com>,
	netdev mailing list <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:33082 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758478AbXIUPnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 11:43:25 -0400
In-Reply-To: <1190382366.4231.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2007-21-09 at 09:37 -0400, jamal wrote:
>   
>> On Fri, 2007-21-09 at 14:50 +0200, Emil Micek wrote:
>>     
>>> On Fri, 2007-09-21 at 07:59 -0400, jamal wrote:
>>>       
>>>> Which would make it a bug. AFAIK, the minimum VLAN tagged packet going
>>>> out is 68 bytes.
>>>>         
>>> Are you sure about this? 
>>>       
>> This is what i have always seen. 
>>     
>
> If the first email caused confusion - so will this ;->
> I have never used e1000 for vlan tagging. My view is that if it emits
> (instead of 68B) 64B packets with tags then it is buggy and needs to be
> fixed. Hope that makes sense.
>   
I just re-read the spec, and a bridge *may* pad up to 68, but it is not 
required.
On page 166, it says equipment must be able to handle 64 byte minimums.

See page 22 (section 7.2) of this document:

http://standards.ieee.org/getieee802/download/802.1Q-1998.pdf

Also, page 63, 165, 166

Thanks,
Ben

>
> cheers,
> jamal
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


