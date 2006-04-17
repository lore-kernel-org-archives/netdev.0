From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][RFC] Security marking
Date: Mon, 17 Apr 2006 20:55:20 +0200
Message-ID: <4443E498.4010301@trash.net>
References: <Pine.LNX.4.64.0604160012500.16600@d.namei> <4443D5BA.6060605@trash.net> <Pine.LNX.4.64.0604171440480.17563@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35789 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751206AbWDQSzW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 14:55:22 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0604171440480.17563@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Mon, 17 Apr 2006, Patrick McHardy wrote:
> 
> 
>>>From a pure netfilter POV it would still be nice to have the socket
>>hooks for userspace queueing in socket context and filtering hard
>>to track protocols. My only question is: if I would port the skfilter
>>patches to the current kernel today and fix the unresolved issues,
>>would you still prefer this approach?
> 
> 
> I think the newer model of marking the packets first via Netfilter then 
> interpreting them at the socket layer is superior.  i.e. skfilter is 
> probably not preferred for SELinux now.
> 
> However, it's still useful for incoming user matching for things like 
> user-level firewalling.

OK, thanks. I plan to make it ready for submission eventually, just
wanted to make sure I'm not holding back things.
