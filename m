From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost_net: remove tx polling state
Date: Thu, 11 Apr 2013 16:16:57 -0400 (EDT)
Message-ID: <20130411.161657.2074095162745735091.davem@davemloft.net>
References: <1365663048-38332-1-git-send-email-jasowang@redhat.com>
	<20130411072430.GC17063@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130411072430.GC17063@redhat.com>
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

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 11 Apr 2013 10:24:30 +0300

> On Thu, Apr 11, 2013 at 02:50:48PM +0800, Jason Wang wrote:
>> After commit 2b8b328b61c799957a456a5a8dab8cc7dea68575 (vhost_net: handle polling
>> errors when setting backend), we in fact track the polling state through
>> poll->wqh, so there's no need to duplicate the work with an extra
>> vhost_net_polling_state. So this patch removes this and make the code simpler.
>> 
>> This patch also removes the all tx starting/stopping code in tx path according
>> to Michael's suggestion.
>> 
>> Netperf test shows almost the same result in stream test, but gets improvements
>> on TCP_RR tests (both zerocopy or copy) especially on low load cases.
>> 
>> Tested between multiqueue kvm guest and external host with two direct
>> connected 82599s.
 ...
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Less code and better speed, what's not to like.
> Davem, could you pick this up for 3.10 please?
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied to net-next, thanks everyone.
