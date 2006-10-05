From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: 2.6.18-mm2 boot failure on x86-64
Date: Thu, 05 Oct 2006 08:12:52 -0700
Message-ID: <1160061173.9569.43.camel@dyn9047017100.beaverton.ibm.com>
References: <20060928014623.ccc9b885.akpm@osdl.org>
	 <20061004170659.f3b089a8.akpm@osdl.org> <20061005005124.GA23408@in.ibm.com>
	 <200610050257.53971.ak@suse.de>  <45245B03.2070803@mbligh.org>
	 <1160060020.29690.5.camel@flooterbu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <ak@suse.de>,
	vgoyal@in.ibm.com, Andrew Morton <akpm@osdl.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	kmannth@us.ibm.com, Andy Whitcroft <apw@shadowen.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751472AbWJEPNX@vger.kernel.org>
To: Steve Fox <drfickle@us.ibm.com>
In-Reply-To: <1160060020.29690.5.camel@flooterbu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-10-05 at 09:53 -0500, Steve Fox wrote:
> On Wed, 2006-10-04 at 18:08 -0700, Martin Bligh wrote:
> > Andi Kleen wrote:
> > >>I think most likely it would crash on 2.6.18. Keith mannthey had reported
> > >>a different crash on 2.6.18-rc4-mm2 when this patch was introduced first
> > >>time. Following is the link to the thread.
> > > 
> > > 
> > > Then maybe trying 2.6.17 + the patch and then bisect between that and -rc4?
> > 
> > I think it's fixed already in -git22, or at least it is for the IBM box
> > reporting to test.kernel.org. You might want to try that one ...
> 
> -git22 also panics for me.
> 

Steve,

Can you post the latest panic stack again (with CONFIG_DEBUG_KERNEL) ? 
Last time I couldn't match your instruction dump to any code segment
in the routine. And also, can you post your .config file. I have
an amd64 and em64t machine and both work fine...

Thanks,
Badari
