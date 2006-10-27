From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Check if user has CAP_NET_ADMIN to change congestion
 control algorithm
Date: Fri, 27 Oct 2006 08:48:01 -0700
Message-ID: <45422A31.7070806@osdl.org>
References: <4540F076.70801@psc.edu> <20061026224407.GA2018@c3po.0xdef.net> <20061026235256.GB2018@c3po.0xdef.net> <20061026.170221.99202188.davem@davemloft.net> <20061027104311.GB3967@c3po.0xdef.net> <20061027074102.2a6fef4b@localhost.localdomain> <20061027152157.GB4632@c3po.0xdef.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62651 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750856AbWJ0Psc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 11:48:32 -0400
To: Hagen Paul Pfeifer <hagen@jauu.net>,
	Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>, jheffner@psc.edu,
	netdev@vger.kernel.org
In-Reply-To: <20061027152157.GB4632@c3po.0xdef.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hagen Paul Pfeifer wrote:
> * Stephen Hemminger | 2006-10-27 07:41:02 [-0700]:
>
>   
>> Please no, it makes the socket option useless.
>>     
>
> Technical no, in the sense of usability for everybody yes. You are right
> Stephen, as a programmer I understand you complete!
>
> But on the other side: We know for sure that this IS a problem if we allow
> everybody to "prefer his socket".
>
> In my opinion we should prefer fairness before usability! As John Heffner
> introduce, we can introduce a ranking system for congestion control algorithms -
> but this solution seems a little bit oversized and maybe can't be complete
> guaranteed (complex interaction between the protocols in different
> environment and so on, you know).
>
> HGN
>
>   
If there is a dangerous choice, then it should be removed. Otherwise I can't
see the problem. It is a bigger risk to have to escalate the privileges 
of an application
just to allow it to use something.
