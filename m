From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 2/6] vhost_net: use vhost_add_used_and_signal_n() in
	vhost_zerocopy_signal_used()
Date: Mon, 02 Sep 2013 14:28:37 +0800
Message-ID: <52243015.9080101@redhat.com>
References: <1377836962-49780-1-git-send-email-jasowang@redhat.com>
	<1377836962-49780-3-git-send-email-jasowang@redhat.com>
	<20130902055048.GA19838@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130902055048.GA19838@redhat.com>
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

On 09/02/2013 01:50 PM, Michael S. Tsirkin wrote:
> On Fri, Aug 30, 2013 at 12:29:18PM +0800, Jason Wang wrote:
>> > We tend to batch the used adding and signaling in vhost_zerocopy_callback()
>> > which may result more than 100 used buffers to be updated in
>> > vhost_zerocopy_signal_used() in some cases. So wwitch to use
> switch

Ok.
>> > vhost_add_used_and_signal_n() to avoid multiple calls to
>> > vhost_add_used_and_signal(). Which means much more less times of used index
>> > updating and memory barriers.
> pls put info on perf gain in commit log too
>

Sure.
