From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH -MM] e1000: rewrite hardware initialization code
Date: Tue, 09 Jan 2007 14:24:03 -0800
Message-ID: <45A41603.5000706@intel.com>
References: <45A3D29D.1000202@intel.com> <20070109104525.b0f17316.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932473AbXAIWYJ@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20070109104525.b0f17316.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Tue, 09 Jan 2007 09:36:29 -0800
> Auke Kok <auke-jan.h.kok@intel.com> wrote:
> 
>>      git-pull git://lost.foo-projects.org/~ahkok/git/linux-2.6 e1000
> 
> That tree appears to be based on the -mm git tree?
> 
> That's a somewhat unusual thing to do - a tree which is based on current
> Linus mainline would be preferred, please.  Or on Jeff's netdev tree.


An updated patch is available from git, and applies against netdev-2.6's upstream branch 
(as of commit 77aab8bf22042d1658d4adbca8b71779e7f2d0ff )

     git-pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 e1000

Again, also available per http:

     http://foo-projects.org/~sofar/e1000_hw_init_layer_rewrite-v2-upstream.patch
     http://foo-projects.org/~sofar/e1000_hw_init_layer_rewrite-v2-upstream.patch.bz2

This version contains a few minor adjustments and updates to the one posted earlier this 
morning (and replaces that patch):

1) 82541 bitmask issue
2) 80003es2lan timeout value fix
3) added some more kdoc headers to functions
4) removed #ifdef NETIF_F_TSO6 forgotten by cleanup patch

I hope this patch works for everyone, please let me know if there are still problems.

Cheers,

Auke
