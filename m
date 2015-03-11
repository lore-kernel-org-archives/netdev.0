From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Wed, 11 Mar 2015 08:34:46 -0400
Message-ID: <55003666.3020100@oracle.com>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com> <20150311081909.552e2052@grimm.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20150311081909.552e2052@grimm.local.home>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2015 08:19 AM, Steven Rostedt wrote:
> I removed the Cc list as it was so large, I'm sure that it exceeded the
> LKML Cc size limit, and your email probably didn't make it to the list
> (or any of them).

Thanks. I'll resend in a bit if it doesn't show up on lkml.org.

> On Wed, 11 Mar 2015 07:43:59 -0400
> Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> > As discussed on LSF/MM, kill kmemcheck.
>> > 
>> > KASan is a replacement that is able to work without the limitation of
>> > kmemcheck (single CPU, slow). KASan is already upstream.
>> > 
>> > We are also not aware of any users of kmemcheck (or users who don't consider
>> > KASan as a suitable replacement).
> I use kmemcheck and I am unaware of KASan. I'll try to play with KASan
> and see if it suites my needs.

Fair enough. We knew there are existing kmemcheck users, but KASan should be
superior both in performance and the scope of bugs it finds. It also shouldn't
impose new limitations beyond requiring gcc 4.9.2+.


Thanks,
Sasha
