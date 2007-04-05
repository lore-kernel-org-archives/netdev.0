From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Thu, 5 Apr 2007 13:36:55 +0200
Message-ID: <20070405113655.GA21542@elte.hu>
References: <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com>
	<20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com>
	<20070404212103.GA19026@elte.hu>
	<1175728768.12230.593.camel@localhost.localdomain>
	<20070405093033.GC25448@elte.hu>
	<4614C846.7070605@qumranet.com> <20070405102656.GA5595@elte.hu>
	<4614DCE1.70905@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4614DCE1.70905-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
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


* Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org> wrote:

> [...] But the difference in cruftiness between kvm and qemu code 
> should not enter into the discussion of where to do things.

i agree that it doesnt enter the discussion for the *PIC question, but 
it very much enters the discussion for the question that i replied to:

> > > You didn't quote Anthony's point about "it's more about there not 
> > > being good enough userspace interfaces to do network IO."
> > > 
> > > It's easier to write a kernel-space network driver, but it's not
> > >  obviously the right thing to do until we can show that an 
> > > efficient packet-level userspace interface isn't possible.  I 
> > > don't think that's been done, and it would be interesting to try.

prototyping new kernel APIs to implement user-space network drivers, on 
a crufty codebase is not something that should be done lightly. Any 
negative result will not bring us any real conclusion. (was the failure 
due to the concept, due the API or due to the crufty codebase?)

(but ... this is really a side-track issue for the *PIC question at 
hand. PICs are not network devices, they are essential platform 
components and almost an extended part of the CPU.)

	Ingo

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
