From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] virtio_net: fix refill related races
Date: Tue, 20 Dec 2011 11:31:54 -0800
Message-ID: <20111220193154.GG10752@google.com>
References: <20111207152120.GA23417@redhat.com>
	<8739cvisqe.fsf@rustcorp.com.au>
	<20111211144428.GB14381@redhat.com>
	<878vmioh10.fsf@rustcorp.com.au> <20111212115405.GB7946@redhat.com>
	<87iplltd0g.fsf@rustcorp.com.au>
	<20111220190908.GC25689@redhat.com>
	<20111220190946.GD10752@google.com>
	<20111220193055.GA26392@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amit Shah <amit.shah@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111220193055.GA26392@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2011 at 09:30:55PM +0200, Michael S. Tsirkin wrote:
> Hmm, in that case it looks like a nasty race could get
> triggered, with try_fill_recv run on multiple CPUs in parallel,
> corrupting the linked list within the vq.
> 
> Using the mutex as my patch did will fix that naturally, as well.

Don't know the code but just use nrt wq.  There's even a system one
called system_nrq_wq.

Thanks.

-- 
tejun
