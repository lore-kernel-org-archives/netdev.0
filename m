From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Wed, 03 Oct 2012 12:53:34 +0200
Message-ID: <506C192E.5060700@redhat.com>
References: <cover.1348824232.git.mst@redhat.com>
	<87vces2gxq.fsf__45058.6618776017$1349247807$gmane$org@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <levinsasha928@gmail.com>,
	virtualization@lists.linux-foundation.org,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>, avi@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87vces2gxq.fsf__45058.6618776017$1349247807$gmane$org@rustcorp.com.au>
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

Il 03/10/2012 08:44, Rusty Russell ha scritto:
> There's a reason I haven't done this.  I really, really dislike "my
> implemention isn't broken" feature bits.  We could have an infinite
> number of them, for each bug in each device.

However, this bug affects (almost) all implementations and (almost) all
devices.  It even makes sense to reserve a transport feature bit for it
instead of a device feature bit.

Paolo
