From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [patch] Change Networking mibs to use kmalloc_percpu -- 1/3
Date: Wed, 4 Dec 2002 20:34:27 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021204223427.GA23578@conectiva.com.br>
References: <20021204180510.C17375@in.ibm.com> <20021204.090152.97851491.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kiran@in.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   akpm@digeo.com, dipankar@in.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20021204.090152.97851491.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, Dec 04, 2002 at 09:01:52AM -0800, David S. Miller escreveu:
>    From: Ravikiran G Thirumalai <kiran@in.ibm.com>
>    Date: Wed, 4 Dec 2002 18:05:10 +0530
> 
>    Here's a patchset to enable networking mibs to use kmalloc_percpu instead
>    of the traditional padded NR_CPUS arrays.
>    
>    Advantages:
>    1. Removes NR_CPUS bloat due to static definition
>    2. Can support node local allocation
>    3. Will work with modules
>    
> I totally support this work.  Once the kmalloc percpu bits hit
> Linus's tree, just retransmit these diffs to me privately and
> I'll put them into my net-2.5 tree.

Cool stuff! I was planning to macroise this so that things like this would be
possible without source impact but now its just there, keep it up :-)

- Arnaldo
