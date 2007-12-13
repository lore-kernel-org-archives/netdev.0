From: Dor Laor <dor.laor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [virtio-net][PATCH] Don't arm tx hrtimer with a
 constant 500us each transmit
Date: Thu, 13 Dec 2007 10:44:26 +0200
Message-ID: <4760F0EA.7010004@qumranet.com>
References: <475FD9E8.1060109@qumranet.com>
	<200712121419.50400.borntraeger@de.ibm.com>
	<475FED88.7020304@qumranet.com>
	<200712121733.07804.borntraeger@de.ibm.com>
Reply-To: dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization <virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
To: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <200712121733.07804.borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Christian Borntraeger wrote:
>
> Am Mittwoch, 12. Dezember 2007 schrieb Dor Laor:
> > Christian Borntraeger wrote:
> > >
> > > Am Mittwoch, 12. Dezember 2007 schrieb Dor Laor:
> > > > --- a/drivers/net/virtio_net.c
> > > > +++ b/drivers/net/virtio_net.c
> > > > @@ -406,10 +405,10 @@ again:
> > >
> > > Hmm, while I agree in general with the patch, I fail to find the 
> proper
> > > version of virtio_net where this patch applies. I tried kvm.git and
> > > linux-2.6.git from kernel.org. Can you give me a pointer to the
> repository
> > > where you work on virtio?
> > >
> > Sorry for that, I added some debug prints of my one.
> > Here it is: *git clone
> > git*://kvm.*qumranet*.com/home/*dor*/src/linux-2.6-nv use branch 
> 'virtio'.
>
> Ah, ok. I will look into that branch.
>
> > BTW: what git repository do you use?
>
> I use Avis git from kernel.org:
> git://git.kernel.org/pub/scm/linux/kernel/git/avi/kvm
>
I patch it with Anthony's http://hg.codemonkey.ws/linux-virtio/
Over that I send the patches. One can use my repository directly.
>
> Christian
>


-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
