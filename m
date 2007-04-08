From: Muli Ben-Yehuda <muli-7z/5BgaJwgfQT0dZR+AlfA@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Sun, 8 Apr 2007 12:04:29 +0300
Message-ID: <20070408090429.GB26210@rhun.ibm.com>
References: <4613CC01.1090500@qumranet.com> <4613CDB2.4000903@codemonkey.ws>
	<4613D001.3040606@qumranet.com> <20070404200112.GA6070@elte.hu>
	<4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu>
	<1175728768.12230.593.camel@localhost.localdomain>
	<4614A294.3000607@qumranet.com>
	<1175821357.12230.642.camel@localhost.localdomain>
	<46187F4E.1080807@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46187F4E.1080807-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
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

On Sun, Apr 08, 2007 at 08:36:14AM +0300, Avi Kivity wrote:

> That is not the common case.  Nor is it true when there is a
> mismatch between the card's capabilties and guest expectations and
> constraints.  For example, guest memory is not physically contiguous
> so a NIC that won't do scatter/gather will require bouncing (or an
> iommu, but that's not here yet).

Actually, Allen Key from Intel just posted the first VT-d patches to
xen-devel a couple of days ago. I wonder if anyone is working on kvm
support (which would require Linux support).

Cheers,
Muli

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
