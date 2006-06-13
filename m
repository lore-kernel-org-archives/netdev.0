From: John Heffner <jheffner@psc.edu>
Subject: Re: 2.6.17: networking bug??
Date: Tue, 13 Jun 2006 13:39:42 -0400
Message-ID: <448EF85E.50405@psc.edu>
References: <448EC6F3.3060002@rtr.ca> <448ECB09.3010308@rtr.ca> <448ED2FC.2040704@rtr.ca> <448ED9B3.8050506@rtr.ca> <448EEE9D.10105@rtr.ca> <448EF45B.2080601@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1250; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:24794 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S1750799AbWFMRjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 13:39:54 -0400
To: Mark Lord <lkml@rtr.ca>
In-Reply-To: <448EF45B.2080601@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Lord wrote:
> John / David:  Any ideas on what's gone awry here?
> 
> 

Yes, you have some sort of a broken middlebox in your path (firewall, 
transparent proxy, or similar) that doesn't correctly handle window 
scaling.  Check out this thread: 
<http://marc.theaimsgroup.com/?l=linux-netdev&m=114478312100641&w=2>.

The best thing you can do is try to find this broken box and inform its 
owner that it needs to be fixed.  (If you can find out what it is, I'd 
be interested to know.)  In the meantime, disabling window scaling will 
work around the problem for you.

   -John
