From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] Change Networking mibs to use kmalloc_percpu -- 1/3
Date: Wed, 04 Dec 2002 09:01:52 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021204.090152.97851491.davem@redhat.com>
References: <20021204180510.C17375@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, akpm@digeo.com,
   dipankar@in.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kiran@in.ibm.com
In-Reply-To: <20021204180510.C17375@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ravikiran G Thirumalai <kiran@in.ibm.com>
   Date: Wed, 4 Dec 2002 18:05:10 +0530

   Here's a patchset to enable networking mibs to use kmalloc_percpu instead
   of the traditional padded NR_CPUS arrays.
   
   Advantages:
   1. Removes NR_CPUS bloat due to static definition
   2. Can support node local allocation
   3. Will work with modules
   
I totally support this work.  Once the kmalloc percpu bits hit
Linus's tree, just retransmit these diffs to me privately and
I'll put them into my net-2.5 tree.

Thanks.
