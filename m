From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][MIPS][7/7] AR7: ethernet
Date: Thu, 6 Sep 2007 17:41:02 -0700
Message-ID: <20070906174102.cc5a59e5.akpm@linux-foundation.org>
References: <200708201704.11529.technoboy85@gmail.com>
	<200709061734.11170.technoboy85@gmail.com>
	<20070906153025.7cb71cb1.akpm@linux-foundation.org>
	<200709070121.42629.technoboy85@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ejka@imfi.kspu.ru, jgarzik@pobox.com,
	netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@coreworks.de
To: Matteo Croce <technoboy85@gmail.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <200709070121.42629.technoboy85@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

> On Fri, 7 Sep 2007 01:21:41 +0200 Matteo Croce <technoboy85@gmail.com> wrote:
> > The patch introduces vast number of volatile structure fields.  Please see
> > Documentation/volatile-considered-harmful.txt.
> 
> Removing them and the kernel hangs at module load

They can't just be removed.  Please see the document.  There are I/O APIs
which, if properly used, make volatile unneeded.
