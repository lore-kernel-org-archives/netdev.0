From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: Re: [PATCH V8 net-next 0/6] xen-net{back,
 front}: Multiple transmit and receive queues
Date: Wed, 21 May 2014 14:42:47 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0380FD1@AMSPEX01CL01.citrite.net>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
	<526369072.20140514160923@eikelenboom.it>
	<20140514141347.GR6332@zion.uk.xensource.com>
	<53739757.5060905@citrix.com>
	<1296806729.20140514203719@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	David Vrabel <david.vrabel@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Andrew Bennieston <andrew.bennieston@citrix.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1296806729.20140514203719@eikelenboom.it>
Content-Language: en-US
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> Sent: 14 May 2014 19:37
> To: Andrew Bennieston
> Cc: Wei Liu; xen-devel@lists.xenproject.org; davem@davemloft.net; Ian
> Campbell; netdev@vger.kernel.org; Paul Durrant; David Vrabel; Zoltan Kiss
> Subject: Re: [Xen-devel] [PATCH V8 net-next 0/6] xen-net{back, front}:
> Multiple transmit and receive queues
> 
> 
> Wednesday, May 14, 2014, 6:18:31 PM, you wrote:
> 
> > On 14/05/14 15:13, Wei Liu wrote:
> >> On Wed, May 14, 2014 at 04:09:23PM +0200, Sander Eikelenboom wrote:
> >>>
> >>> Wednesday, May 14, 2014, 3:52:24 PM, you wrote:
> >>>
> >>>> This patch series implements multiple transmit and receive queues (i.e.
> >>>> multiple shared rings) for the xen virtual network interfaces.
> >>>
> >>>> The series is split up as follows:
> >>>>   - Patch 1 brings the 'grant_copy_op' array back into struct xenvif, in
> >>>>     preparation for multi-queue support. See the patch itself for more
> details.
> >>>> - Patches 2 and 4 factor out the queue-specific data for netback and
> >>>>    netfront respectively, and modify the rest of the code to use these
> >>>>    as appropriate.
> >>>> - Patches 3 and 5 introduce new XenStore keys to negotiate and use
> >>>>    multiple shared rings and event channels, and code to connect these
> >>>>    as appropriate.
> >>>> - Patch 6 documents the XenStore keys required for the new feature
> >>>>    in include/xen/interface/io/netif.h
> >>>
> >>>> All other transmit and receive processing remains unchanged, i.e. there
> >>>> is a kthread per queue and a NAPI context per queue.
> >>>
> >>>> The performance of these patches has been analysed in detail, with
> >>>> results available at:
> >>>
> >>> <snip>
> >>>
> >>> Would it be possible to also put these somewhere in a tree (or branch of
> the
> >>> xen-tree), so it is more easy to pull and test ?
> >>>
> >>
> >> I cannot speak for Andrew. FWIW you can save this thread and use 'git
> >> am' to apply them to 'net-next'.
> >>
> >> Wei.
> 
> > I don't currently have a public-facing git repo for this. If you'd
> > prefer I can send you the patches directly in a tarball, which you may
> > be able to apply more easily than grabbing them from email threads?
> 
> Got the patches from the thread .. but as i expected they interfere with
> Zoltan's v3 fix for 3.15.
> 

I realize there will be conflict when Zoli's patch (for net) and these patches (for net-next) come together, but I don't see these in the patchworks queue at all. Did they get lost somewhere?

  Paul
