From: rapier <rapier@psc.edu>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 16:02:13 -0500
Message-ID: <54909DD5.5070202@psc.edu>
References: <54908FAD.5060500@psc.edu>	<20141216.150354.64901094367530710.davem@davemloft.net>	<54909278.6090806@psc.edu> <20141216.151823.2276708539799601894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:53549 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670AbaLPVCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 16:02:16 -0500
In-Reply-To: <20141216.151823.2276708539799601894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/16/14 3:18 PM, David Miller wrote:
> From: rapier <rapier@psc.edu>
> Date: Tue, 16 Dec 2014 15:13:44 -0500
>
>> On 12/16/14, 3:03 PM, David Miller wrote:
>>
>>> You shouldn't need to export any symbols.
>>
>> As a point of clarification - is it acceptable to export symbols for
>> use with in tree modules such as tcp_htcp? We are more than willing to
>> do the work required to bring this in line with best practices.
>
> I'm saying for data and TCP statistics collection, you shouldn't need
> to add any new symbol exports.

We've been able to identify that as the code stands we only need one 
export for the KIS. That being said, I understand if that's one too 
many. The DLKM (which hasn't been submitted) does require two additional 
symbols and that's an oversight on our part. We'll work to eliminate 
those as well.

> Keep this in the main kernel, nothing external should be needed.
>
> Extending tcp_info or similar is the only reasonable way to implement
> this stuff.

I understand where you are coming from. I do believe that our 
methodology provides some advantages over a tcp_info solution. I'll 
provide some information on that tomorrow after I've had a chance to 
talk about this in more depth with our dev team. That being said, we 
only really care about the instrument set being incorporated as such we 
will take a closer look tcp_info shortly.

Chris
