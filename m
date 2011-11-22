From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Mon, 21 Nov 2011 21:59:18 -0800
Message-ID: <20111121215918.febd9fd4.akpm@linux-foundation.org>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
	<4ECB37E4.6020204@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Florian Mickler <florian@mickler.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <4ECB37E4.6020204@linux.vnet.ibm.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Nov 2011 11:19:24 +0530 "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> wrote:

> > Subject    : khugepaged blocks suspend2ram (3.2.0-rc1-00252-g8f042aa)
> > Submitter  : Sergei Trofimovich <slyich@gmail.com>
> > Date       : 2011-11-12 10:48
> > Message-ID : 20111112104859.7744b282@sf.home
> > References : https://lkml.org/lkml/2011/11/12/11
> > 
> 
> Andrea's patch already fixes this issue, which was reported first by
> Jiri Slaby. https://lkml.org/lkml/2011/11/11/93
> I remember Andrew Morton taking this patch in his -mm tree. But it is
> not in mainline yet. So can we consider this closed or not?

grr, nothing in that patch's changelog indicates that it fixed a
regression nor that it fixed an infinite blockage of suspend.

I moved it to my 3.2 queue, thanks.
