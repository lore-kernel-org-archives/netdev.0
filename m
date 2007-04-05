From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Thu, 5 Apr 2007 12:55:40 +0200
Message-ID: <20070405105540.GA12124@elte.hu>
References: <4613BF07.50606@qumranet.com> <4613C993.9020405@codemonkey.ws>
	<4613CC01.1090500@qumranet.com> <4613CDB2.4000903@codemonkey.ws>
	<4613D001.3040606@qumranet.com> <20070404200112.GA6070@elte.hu>
	<4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu>
	<1175728768.12230.593.camel@localhost.localdomain>
	<20070405093033.GC25448@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070405093033.GC25448-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org> wrote:

> * Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org> wrote:
> 
> > It's easier to write a kernel-space network driver, but it's not 
> > obviously the right thing to do until we can show that an efficient 
> > packet-level userspace interface isn't possible.  I don't think 
> > that's been done, and it would be interesting to try.
> 
> yes, i agree in theory, [...]

let me explain my position a bit more verbosely:

i agree in terms of 'network driver' (and more generally in terms of 
'device', which includes network, storage, console, etc. devices): 
having a user-space driver option should still be possible and it should 
be integrated well. Qemu is quite rich and flexible in these areas and 
we dont want to throw away or isolate that body of code.

but i dont agree in terms of PIC code, which is the main argument in 
this particular thread. There's little precedent for any add-ons for 
PICs in user-space, nor any particular PIC handling richness in Qemu 
that we'd like to preserve.

	Ingo

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
