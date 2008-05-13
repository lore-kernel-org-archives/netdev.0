From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] DCCP: Fix to reset the connection with Reset Code 5	Option
 Error while receive invalid option
Date: Tue, 13 May 2008 17:57:55 +0800
Message-ID: <48296623.8040405@cn.fujitsu.com>
References: <48294E9C.4060209@cn.fujitsu.com> <20080513083033.GA11707@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Wei Yongjun <yjwei@cn.fujitsu.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50910 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751904AbYEMJ5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 05:57:34 -0400
In-Reply-To: <20080513083033.GA11707@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gerrit Renker:

 Sorry for my stupid patch since I can get the test git tree.

 But, Is there any other way to get the git tree? I download a patch 
from following URL:
  
http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/test-tree_2.6.25.diff.gz
 I used this patch to my linux-2.6.25, there is error happend. and it 
has compile error too.

 Is this patch is based on linux-2.6.25? If I want to send a patch, I 
must create my patch base on what version of kernel?

Thanks.

Gerrit Renker wrote:
> Quoting Wei Yongjun:
>   
>> If endpoint received invalid option, it must reset the connection with  
>> Reset Code 5 "Option Error", but current kernel send reset with Reset  
>> Code 4 "Packet Error".
>>
>>     
> Ack. However, this has already been fixed in the test tree where dccp_parse()
> both sets the Reset code and fills in the Data1..3 fields (not done by this patch).
>
> Within a span of two weeks this is the fourth DCCP patch which fixes bugs
> that already have fixes in the DCCP test tree. The same problems are fixed
> in two different locations.
>
> If you are doing DCCP work, please consider 
> http://www.linux-foundation.org/en/Net:DCCP_Testing#How_to_obtai
