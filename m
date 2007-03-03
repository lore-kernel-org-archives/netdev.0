From: John Heffner <jheffner@psc.edu>
Subject: Re: SWS for rcvbuf < MTU
Date: Sat, 03 Mar 2007 18:40:12 -0500
Message-ID: <45EA075C.5010406@psc.edu>
References: <200703021521.58821.alexandre.sidorenko@hp.com>	<20070302.123325.28790131.davem@davemloft.net>	<45E89437.3000902@psc.edu> <20070302.133839.17868570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexandre.sidorenko@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:54108 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788AbXCCXkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2007 18:40:21 -0500
In-Reply-To: <20070302.133839.17868570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: John Heffner <jheffner@psc.edu>
> Date: Fri, 02 Mar 2007 16:16:39 -0500
> 
>> Please don't apply the patch I sent.  I've been thinking about this a 
>> bit harder, and it may not fix this particular problem.  (Hard to say 
>> without knowing exactly what it is.)  As the comment above 
>> __tcp_select_window() states, we do not do full receive-side SWS 
>> avoidance because of header prediction.
>>
>> Alex, you're right I missed that special zero-window case.  I'm still 
>> not quite sure I'm completely happy with this patch.  I'd like to think 
>> about this a little bit harder...
> 
> Ok

Alright, I've thought about it a bit more, and I think the patch I sent 
should work.  Alex, any opinion?  Any way you can test this out?

Thanks,
   -John
