From: Jerome Glisse <glisse@freedesktop.org>
Subject: Re: 2.6.34-rc5: Reported regressions from 2.6.33
Date: Wed, 21 Apr 2010 10:57:39 +0200
Message-ID: <20100421085739.GA2576@barney.localdomain>
References: <deuQKFRcc0B.A.3EG.BRSzLB@tosh>
	<20100420135636.GA10674@elliptictech.com>
	<201004210715.38621.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nick Bowler <nbowler@elliptictech.com>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        DRI <dri-devel@lists.sourceforge.net>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux PM List <linux-pm@lists.linux-foundation.org>,
        Maciej Rutecki <maciej.rutecki@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <201004210715.38621.rjw@sisk.pl>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 21, 2010 at 07:15:38AM +0200, Rafael J. Wysocki wrote:
> On Tuesday 20 April 2010, Nick Bowler wrote:
> > On 05:15 Tue 20 Apr     , Rafael J. Wysocki wrote:
> > > If you know of any other unresolved regressions from 2.6.33, please let us
> > > know either and we'll add them to the list.  Also, please let us know
> > > if any of the entries below are invalid.
> > 
> > Please list these two similar regressions from 2.6.33 in the r600 DRM:
> > 
> >  * r600 CS checker rejects GL_DEPTH_TEST w/o depth buffer:
> >            https://bugs.freedesktop.org/show_bug.cgi?id=27571
> > 
> >  * r600 CS checker rejects narrow FBO renderbuffers:
> >            https://bugs.freedesktop.org/show_bug.cgi?id=27609
> 
> Do you want to me to add them as one entry or as two separate bugs?
> 
> Rafael
> 

First one is userspace bug, i need to look into the second one.
ie we were lucky the hw didn't lockup without depth buffer and
depth test enabled.

Cheers,
Jerome
