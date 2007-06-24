From: David Miller <davem@davemloft.net>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 22:45:11 -0700 (PDT)
Message-ID: <20070623.224511.00323567.davem@davemloft.net>
References: <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com>
	<20070623.135737.22037347.davem@davemloft.net>
	<m1ir9e8i2r.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	jeff@garzik.org, yoshfuji@linux-ipv6.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57188
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753328AbXFXFow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 01:44:52 -0400
In-Reply-To: <m1ir9e8i2r.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 23 Jun 2007 15:41:16 -0600

> If you want the argument to compile out.  That is not a problem at all.
> I dropped that part from my patch because it makes infrastructure more
> complicated and there appeared to be no gain.  However having a type
> that you can pass that the compiler can optimize away is not a
> problem.  Basically you just make the argument:
> 
> typedef struct {} you_can_compile_me_out;  /* when you don't want it. */
> typedef void * you_can_compile_me_out;     /* when you do want it. */
> 
> And gcc will generate no code to pass the argument when you compile
> it out.

I don't want to have to see or be aware of the types or the
fact that we support namespaces when I work on the networking
code.

This is why I like the security layer in the kernel we have,
I can disable it and it's completely not there.  And I can
be completely ignorant of it's existence when I work on the
networking stack.
