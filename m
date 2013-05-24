From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: updated: kvm networking todo wiki
Date: Fri, 24 May 2013 14:35:42 +0300
Message-ID: <20130524113542.GA7046@redhat.com>
References: <20130523085034.GA16142@redhat.com> <519F35B7.6010408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, lmr@redhat.com, "Xin,
	Xiaohui" <xiaohui.xin@intel.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, Shirley Ma <mashirle@us.ibm.com>,
	virtualization@lists.linux-foundation.org,
	David Stevens <dlstevens@us.ibm.com>, qemu-devel@nongnu.org,
	vyasevic@redhat.com, herbert@gondor.hengli.com.au,
	Anthony Liguori <anthony@codemonkey.ws>, jdike@linux.intel.com,
	sri@linux.vnet.ibm.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <519F35B7.6010408@redhat.com>
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

On Fri, May 24, 2013 at 05:41:11PM +0800, Jason Wang wrote:
> On 05/23/2013 04:50 PM, Michael S. Tsirkin wrote:
> > Hey guys,
> > I've updated the kvm networking todo wiki with current projects.
> > Will try to keep it up to date more often.
> > Original announcement below.
> 
> Thanks a lot. I've added the tasks I'm currently working on to the wiki.
> 
> btw. I notice the virtio-net data plane were missed in the wiki. Is the
> project still being considered?

It might have been interesting several years ago, but now that linux has
vhost-net in kernel, the only point seems to be to
speed up networking on non-linux hosts. Since non-linux
does not have kvm, I doubt virtio is a bottleneck.
IMO yet another networking backend is a distraction,
and confusing to users.
In any case, I'd like to see virtio-blk dataplane replace
non dataplane first. We don't want two copies of
virtio-net in qemu.

> > ----
> >
> > I've put up a wiki page with a kvm networking todo list,
> > mainly to avoid effort duplication, but also in the hope
> > to draw attention to what I think we should try addressing
> > in KVM:
> >
> > http://www.linux-kvm.org/page/NetworkingTodo
> >
> > This page could cover all networking related activity in KVM,
> > currently most info is related to virtio-net.
> >
> > Note: if there's no developer listed for an item,
> > this just means I don't know of anyone actively working
> > on an issue at the moment, not that no one intends to.
> >
> > I would appreciate it if others working on one of the items on this list
> > would add their names so we can communicate better.  If others like this
> > wiki page, please go ahead and add stuff you are working on if any.
> >
> > It would be especially nice to add autotest projects:
> > there is just a short test matrix and a catch-all
> > 'Cover test matrix with autotest', currently.
> >
> > Currently there are some links to Red Hat bugzilla entries,
> > feel free to add links to other bugzillas.
> >
> > Thanks!
> >
