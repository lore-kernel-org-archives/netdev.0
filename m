From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Wed, 11 Mar 2015 13:20:52 -0400 (EDT)
Message-ID: <20150311.132052.205877953171712952.davem@davemloft.net>
References: <55003666.3020100@oracle.com>
	<20150311084034.04ce6801@grimm.local.home>
	<55004595.7020304@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <55004595.7020304@oracle.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Wed, 11 Mar 2015 09:39:33 -0400

> On 03/11/2015 08:40 AM, Steven Rostedt wrote:
>> On Wed, 11 Mar 2015 08:34:46 -0400
>> Sasha Levin <sasha.levin@oracle.com> wrote:
>> 
>>> > Fair enough. We knew there are existing kmemcheck users, but KASan should be
>>> > superior both in performance and the scope of bugs it finds. It also shouldn't
>>> > impose new limitations beyond requiring gcc 4.9.2+.
>>> >
>> Ouch! OK, then I can't use it. I'm currently compiling with gcc 4.6.3.
>> 
>> It will be a while before I upgrade my build farm to something newer.
> 
> Are you actually compiling new kernels with 4.6.3, or are you using older
> kernels as well?
> 
> There's no real hurry to kill kmemcheck right now, but we do want to stop
> supporting that in favour of KASan.

Is the spectrum of CPU's supported by this GCC feature equal to all of the
CPU's supported by the kernel right now?

If not, removing kmemcheck will always be a regression for someone.
