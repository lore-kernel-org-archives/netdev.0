From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Bugme-new] [Bug 8778] New: Ocotea board: kernel reports access
 of bad area during boot with DEBUG_SLAB=y
Date: Mon, 23 Jul 2007 13:34:50 -0700
Message-ID: <20070723133450.3de91b33@schroedinger.engr.sgi.com>
References: <bug-8778-10286@http.bugzilla.kernel.org/>
	<20070718005253.942f0464.akpm@linux-foundation.org>
	<20070718083425.GA29722@gate.ebshome.net>
	<1184766070.3699.2.camel@zod.rchland.ibm.com>
	<20070718155940.GB29722@gate.ebshome.net>
	<20070718095537.d344dc0a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eugene Surovegin <ebs@ebshome.net>, linux-mm@kvack.org,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	bart.vanassche@gmail.com, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, linuxppc-embedded@ozlabs.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:60915 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762780AbXGWUew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 16:34:52 -0400
In-Reply-To: <20070718095537.d344dc0a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007 09:55:37 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> hm.  It should be the case that providing SLAB_HWCACHE_ALIGN at
> kmem_cache_create() time will override slab-debugging's offsetting
> of the returned addresses.


That is true for SLUB but not in SLAB. SLAB has always ignored
SLAB_HWCACHE_ALIGN when debugging is on because of the issues involved
in placing the redzone values etc.  Could be fun to fix.

