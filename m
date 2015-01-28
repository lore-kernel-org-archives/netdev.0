From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/3] ipv6: Select fragment id during UFO/GSO
	segmentation if not set.
Date: Wed, 28 Jan 2015 11:39:05 +0100
Message-ID: <1422441545.4678.33.camel@stressinduktion.org>
References: <1422283026-27832-1-git-send-email-vyasevic@redhat.com>
	<1422283026-27832-2-git-send-email-vyasevic@redhat.com>
	<1422326874.31046.239.camel@decadent.org.uk>
	<20150127084208.GB21584@redhat.com>
	<1422366458.13969.11.camel@stressinduktion.org>
	<54C7A007.6050707@redhat.com>
	<1422374551.13969.35.camel@stressinduktion.org>
	<20150127160808.GA10765@redhat.com>
	<1422433508.4678.14.camel@stressinduktion.org>
	<20150128094658.GB16775@redhat.com>
	<1422441242.4678.32.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevich@gmail.com>,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	Ben Hutchings <ben@decadent.org.uk>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1422441242.4678.32.camel@stressinduktion.org>
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

On Mi, 2015-01-28 at 11:34 +0100, Hannes Frederic Sowa wrote:
> 
> > And now it's even easier - just patch the hypervisor, and all VMs
> > automatically benefit.
> 
> Sometimes the hypervisor is not under my control. You would need to
> patch both kernels in your case - non gso frames would still get the
> fragmentation id generated in the host kernel.

Actually this now became my biggest concern. :/

Bye,
Hannes
