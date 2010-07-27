From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with per-vhost
 kthread
Date: Tue, 27 Jul 2010 10:21:30 +0200
Message-ID: <4C4E970A.2030607@kernel.org>
References: <20100722155840.GA1743@redhat.com> <4C48B664.9000109@kernel.org> <20100724191447.GA4972@redhat.com> <4C4BEAA2.6040301@kernel.org> <20100726152510.GA26223@redhat.com> <4C4DAB14.5050809@kernel.org> <20100726155014.GA26412@redhat.com> <4C4DB247.9060709@kernel.org> <20100726162346.GD26412@redhat.com> <4C4DDC31.9070206@kernel.org> <20100726201907.GF27644@redhat.com>
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
In-Reply-To: <20100726201907.GF27644@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 07/26/2010 10:19 PM, Michael S. Tsirkin wrote:
> Let's try to define what do we want to achieve then.  Do you want
> code that flushes workers not to block when workers are frozen? How
> will we handle work submitted when worker is frozen?

As I wrote earlier, it's not necessarily about correctness but rather
avoiding unnecessary surprises and of course flushing can and should
stall if the queue is frozen but let's not separate execution of a
work and its completion with something which can take undeterminate
amount of time.

Thanks.

-- 
tejun
