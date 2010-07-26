From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with per-vhost
 kthread
Date: Mon, 26 Jul 2010 21:14:06 +0200
Message-ID: <4C4DDE7E.8030406@kernel.org>
References: <4C06A580.9060300@kernel.org> <20100722155840.GA1743@redhat.com> <4C48B664.9000109@kernel.org> <20100724191447.GA4972@redhat.com> <4C4BEAA2.6040301@kernel.org> <20100726152510.GA26223@redhat.com> <4C4DAB14.5050809@kernel.org> <20100726155014.GA26412@redhat.com> <4C4DB247.9060709@kernel.org> <4C4DB466.6000409@kernel.org> <20100726165114.GA27353@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
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
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100726165114.GA27353@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/26/2010 06:51 PM, Michael S. Tsirkin wrote:
> On Mon, Jul 26, 2010 at 06:14:30PM +0200, Tejun Heo wrote:
>> Just one more thing.
> 
> I noticed that with vhost, flush_work was getting the worker
> pointer as well. Can we live with this API change?

Yeah, the flushing mechanism wouldn't work reliably if the work is
queued to a different worker without flushing, so yeah passing in
@worker might actually be better.

Thanks.

-- 
tejun
