From: Steve Fox <drfickle@linux.vnet.ibm.com>
Subject: Re: select(0, ..) is valid ?
Date: Tue, 22 May 2007 12:49:21 -0500
Message-ID: <1179856161.3124.110.camel@drfickle.rchland.ibm.com>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
	 <20070515104453.f901e91f.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0705151109021.31972@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0705151927360.28895@blonde.wat.veritas.com>
	 <20070516153703.GA26912@kryten>
	 <1179363553.16195.10.camel@dyn9047017100.beaverton.ibm.com>
	 <1179843397.3124.109.camel@drfickle.rchland.ibm.com>
	 <20070522143432.GA1938@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Badari Pulavarty <pbadari@us.ibm.com>,
	Anton Blanchard <anton@samba.org>,
	Hugh Dickins <hugh@veritas.com>,
	Christoph Lameter <clameter@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	sfr@canb.auug.org.au, ak@suse.de, Andy Whitcroft <andyw@uk.ibm.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:54600 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758711AbXEVRt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 13:49:27 -0400
In-Reply-To: <20070522143432.GA1938@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-22 at 07:34 -0700, Nishanth Aravamudan wrote:
> On 22.05.2007 [09:16:37 -0500], Steve Fox wrote:
> > 
> > Andy put this through a couple machines on test.kernel.org and elm3b6
> > was fixed, however elm3b239 still had a boot error.
> > 
> > BUG: at mm/slab.c:777 __find_general_cachep()
> > 
> > Call Trace:
> >  [<ffffffff802729c6>] __kmalloc+0xa6/0xe0
> >  [<ffffffff8021d21b>] cache_k8_northbridges+0x9b/0x120
> 
> I believe this is fixed by:
> 
> http://lkml.org/lkml/2007/5/18/19
> 
> Care to stack it on top and retest?

Looks good. See the "2.6.22-rc2-git1 +1 +1" row on tko. Thanks.

-- 

Steve Fox
IBM Linux Technology Center

