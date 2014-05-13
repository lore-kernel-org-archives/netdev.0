From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v1] vhost: avoid large order allocations
Date: Tue, 13 May 2014 18:15:27 +0300
Message-ID: <20140513151527.GA28517@redhat.com>
References: <1399970133-46783-1-git-send-email-mimu@linux.vnet.ibm.com>
	<1399970133-46783-2-git-send-email-mimu@linux.vnet.ibm.com>
	<20140513084049.GE29442@redhat.com>
	<87tx8tg3a1.fsf@kima.orebokech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ddongch@cn.ibm.com, Michael Mueller <mimu@linux.vnet.ibm.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, borntraeger@de.ibm.com
To: Romain Francoise <romain@orebokech.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87tx8tg3a1.fsf@kima.orebokech.com>
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

On Tue, May 13, 2014 at 04:29:58PM +0200, Romain Francoise wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> 
> > Please dont' do this, extra indirection hurts performance.
> > Instead, please change vhost_net_open and scsi to allocate the whole
> > structure with vmalloc if kmalloc fails, along the lines of
> > 74d332c13b2148ae934ea94dac1745ae92efe8e5
> 
> Back in January 2013, you didn't seem to think it was a good idea:
> 
> https://lkml.org/lkml/2013/1/23/492

Hmm true, and Dave thought the structure's too large.
I'll have to do some benchmarks to see what the effect
of Michael's patch is, performance-wise.
If it's too expensive I can pick up your patch, no need to
repost.

-- 
MST
