From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [GIT PULL] SCTP bug fixes for net-2.6
Date: Wed, 12 Dec 2007 10:30:47 -0500
Message-ID: <475FFEA7.90005@hp.com>
References: <1196351141-24722-1-git-send-email-vladislav.yasevich@hp.com> <b7f21edd0712112229l6219c835w466d8bf43390cf3a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	lksctp-developers@lists.sourceforge.net
To: Jijo Chacko <consultant.bangalore@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:31540 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756203AbXLLPat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 10:30:49 -0500
In-Reply-To: <b7f21edd0712112229l6219c835w466d8bf43390cf3a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jijo Chacko wrote:
> 
> Hello experts,
> 
> [ sorry if  my questions are irrelevent to any one of you ].
> 
> I am trying to develop a frame work, where i  transport all HTTP traffic
> over SCTP. On user space, i can do this easily over SCTP, BSD-style
> sockets. If i am to write a kernel module(say in-kernel web
> client/server) using kernel version of SCTP interfaces, what are the
> available calls now supported ? I see in-kernel implementation like
> NFS/RPC make kernel version of UDP and TCP _sendmsg, i don't find
> similar interfaces for SCTP..

Look at fs/dlm/lowcomms.c

All you need to do is use IPPROTO_SCTP when creating a socket in
the kernel and then I believe you can use all the same calls as TCP/UDP.

-vlad

