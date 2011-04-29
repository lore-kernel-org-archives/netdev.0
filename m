From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for April 29 (bpf_jit)
Date: Fri, 29 Apr 2011 09:26:32 -0700
Message-ID: <20110429092632.26ff1e53.randy.dunlap@oracle.com>
References: <20110429131940.4f4c938f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110429131940.4f4c938f.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Apr 2011 13:19:40 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20110428:


when CONFIG_MODULES is not enabled:

bpf_jit_comp.c:(.text+0x43cc2): undefined reference to `module_free'
(.text+0x4521a): undefined reference to `module_alloc'
(.text+0x453af): undefined reference to `module_free'


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
