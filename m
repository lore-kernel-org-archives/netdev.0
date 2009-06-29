From: Zan Lynx <zlynx@acm.org>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Mon, 29 Jun 2009 10:59:57 -0600
Message-ID: <4A48F30D.8000803@acm.org>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <87eit3l7y6.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, oleg@redhat.com, eric.dumazet@gmail.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [199.45.143.218] ([199.45.143.218]:33878 "EHLO zlynx.org"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751073AbZF2RXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 13:23:34 -0400
In-Reply-To: <87eit3l7y6.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> At least on x86 I can't see how it happens. mb() is only a compile
> time barrier and the compiler doesn't optimize over indirect callbacks
> like __pollwait() anyways.

Just a note about this. That used to be true, that GCC didn't optimize 
indirect calls. However, see -findirect-inlining in GCC 4.4.

I am not saying that it applies here, but it is something to remember.

-- 
Zan Lynx
zlynx@acm.org

"Knowledge is Power.  Power Corrupts.  Study Hard.  Be Evil."
