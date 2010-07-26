From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with
 per-vhost kthread
Date: Mon, 26 Jul 2010 18:51:22 +0300
Message-ID: <20100726155122.GB26412@redhat.com>
References: <20100531160020.GC3067@redhat.com>
 <4C04D41B.4050704@kernel.org>
 <4C06A580.9060300@kernel.org>
 <20100722155840.GA1743@redhat.com>
 <4C48B664.9000109@kernel.org>
 <20100724191447.GA4972@redhat.com>
 <4C4BEAA2.6040301@kernel.org>
 <20100726152510.GA26223@redhat.com>
 <4C4DAB14.5050809@kernel.org>
 <4C4DADD6.90507@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C4DADD6.90507@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 26, 2010 at 05:46:30PM +0200, Tejun Heo wrote:
> On 07/26/2010 05:34 PM, Tejun Heo wrote:
> > Hello,
> > 
> > On 07/26/2010 05:25 PM, Michael S. Tsirkin wrote:
> >> BTW, kthread_worker would benefit from the optimization I implemented
> >> here as well.
> > 
> > Hmmm... I'm not quite sure whether it's an optimization.  I thought
> > the patch was due to feeling uncomfortable about using barriers?  Is
> > it an optimization?
> 
> Yeah, one less smp_mb() in execution path.  The lock dancing in
> flush() is ugly but then again mucking with barriers could be harder
> to understand.  Care to send a patch against wq#for-next tree?
> 
> Thanks.

Sure. Where's that, exactly?

> -- 
> tejun
