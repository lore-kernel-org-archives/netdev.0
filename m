From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [SCTP] Initialization collision problem
Date: Wed, 04 Apr 2007 11:44:32 -0400
Message-ID: <4613C7E0.3030705@hp.com>
References: <5F14EEE91CB6694A86535A0A028D9C5501555FEF@tx14exm60.ds.mot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"lksctp-developers@lists.sourceforge.net"
	<lksctp-developers@lists.sourceforge.net>
To: Isaula Oscar-QOI000 <Oscar.Isaula@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:60390 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992974AbXDDPoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 11:44:34 -0400
In-Reply-To: <5F14EEE91CB6694A86535A0A028D9C5501555FEF@tx14exm60.ds.mot.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[For SCTP questions, please use netdev or lksctp-developers list]

Hi Oscar

Isaula Oscar-QOI000 wrote:
> I ran into a problem where LKSCTP is reporting a SCTM_COMM_UP indication
> to the User application but is giving back a value of zero for the
> assoc_id.
> 
> Attached are the SCTP debugs for the period in question.
> 
> A couple of things that I would like to note about my setup. One is that
> I'm running Kernel version 2.6.10 (I know is old but I can't move to a
> newer version due to custom drivers). The second thing is that the link
> between the two SCTP node is a very noisy and some messages are getting
> lost (i.e. the INIT_ACK from the peer in this particular case).
> 
> After analyzing the SCTP code I came out with the following code
> changes:
> 

It does appear to be a genuine bug in lkSCTP, but your solution is
not correct.

The problem is that the original association didn't get the
association id yet in this particular scenario.

Let me take a deeper look at this to see if I can figure our
a better solution.

Thanks
-vlad
