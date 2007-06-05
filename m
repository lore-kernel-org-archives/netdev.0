From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: What test suite exists for SCTP
Date: Tue, 05 Jun 2007 16:54:09 -0400
Message-ID: <4665CD71.7050306@hp.com>
References: <4665C85C.5030803@mvista.com> <4665C9C8.6070504@hp.com> <4665CBC0.7030809@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Net Dev <netdev@vger.kernel.org>
To: Paolo Galtieri <pgaltieri@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:41282 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763043AbXFEUyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 16:54:11 -0400
In-Reply-To: <4665CBC0.7030809@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paolo Galtieri wrote:
> Vlad,
>  I'm looking for something that exercises the SCTP stack.   Something
> that can be run against different kernel versions for comparing features
> and regression testing.
> 

lksctp-tools git repo is a good start.  There 2 different sets of test:

1.  Frame tests in lksctp-tools/test.  These run the kernel sctp code in
userspace and are programmable to do whatever you want.  You can add tests
to cover new functionality or ever force corner cases.  The only limitation
of these is that you can't simulate race conditions.

2.  Userspace functional tests in lksctp-tools/src/func_tests.  These are mostly
API tests.

That's a good start.  You can add to it anything that could be missing.

One warning about frame tests.  You need different version of them for each
different kernel version.  They depend on the kernel internals and when those change
we have to continually change these tests.

-vlad
