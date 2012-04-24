From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: linux-next: Tree for Apr 23 (ax.25 sysctl)
Date: Mon, 23 Apr 2012 17:16:56 -0700
Message-ID: <m1vckqrnk7.fsf@fess.ebiederm.org>
References: <20120423170701.c96e402234b1387dece11dda@canb.auug.org.au>
	<4F95828A.8050403@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F95828A.8050403@xenotime.net> (Randy Dunlap's message of "Mon,
	23 Apr 2012 09:25:46 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap <rdunlap@xenotime.net> writes:

> On 04/23/2012 12:07 AM, Stephen Rothwell wrote:
>
>> Hi all,
>> 
>> Changes since 20120420:
>
>
>
> include/net/ax25.h:447:75: error: expected ';' before '}' token
>
>
> static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0 };
> static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {};
>
> Is this from Eric B.'s sysctl patches?

Sort of.  I made the function per device and return 0.

I missed the inner ';' when I made the change.  The outer '};' has
been there for years and has been weird but harmless.

Patch to fix it in a moment.

Eric


> First function:  move ';' inside braces.
> Second function:  drop the ';'.
