From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix 64bit bugs in dscc44.c II
Date: Wed, 8 Oct 2003 09:10:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008091050.11b2acb7.davem@redhat.com>
References: <20031007175953.GA1802@averell>
	<20031008084205.5c81faac.davem@redhat.com>
	<20031008155548.GB16937@wotan.suse.de>
	<20031008090132.2b58c067.davem@redhat.com>
	<20031008160859.GD16937@wotan.suse.de>
	<20031008161149.GA8134@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, ak@muc.de, ncorbic@sangoma.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031008161149.GA8134@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> BTW my change fixed the warning.

I know, but it added a new one.

> It's somewhat ugly to store pointers in unsigned long I agree,

I have _NO_ problem with this, all I'm asking you to do is:

-	foo = ioremap_nocache(...);
+ 	foo = (unsigned long) ioremap_nocache(...);
