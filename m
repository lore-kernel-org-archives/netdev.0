From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] Make rt_cache_stat use kmalloc_percpu
Date: Fri, 20 Dec 2002 23:05:28 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021220.230528.106417474.davem@redhat.com>
References: <20021216192212.C26076@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, dipankar@in.ibm.com,
   akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kiran@in.ibm.com
In-Reply-To: <20021216192212.C26076@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ravikiran G Thirumalai <kiran@in.ibm.com>
   Date: Mon, 16 Dec 2002 19:22:12 +0530

   Here's another patch to use kmalloc_percpu.  As usual, this removes
   NR_CPUS bloat, can work when modulized and helps node local allocation.

I can't consider this seriously until the kmalloc_percpu stuff
actually makes it into Linus's tree.  Last I checked, Andrew had
a lot of legitimate gripes with the ideas.
