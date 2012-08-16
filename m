From: David Miller <davem@davemloft.net>
Subject: Re: [net V2] act_mirred: do not drop packets when fails to mirror
 it
Date: Thu, 16 Aug 2012 14:55:01 -0700 (PDT)
Message-ID: <20120816.145501.2026059988735122378.davem@davemloft.net>
References: <1345099467-40922-1-git-send-email-jasowang@redhat.com>
	<1345119107.5398.0.camel@mojatatu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345119107.5398.0.camel@mojatatu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Thu, 16 Aug 2012 08:11:47 -0400

> On Thu, 2012-08-16 at 14:44 +0800, Jason Wang wrote:
>> We drop packet unconditionally when we fail to mirror it. This is not intended
>> in some cases. Consdier for kvm guest, we may mirror the traffic of the bridge
>> to a tap device used by a VM. When kernel fails to mirror the packet in
>> conditions such as when qemu crashes or stop polling the tap, it's hard for the
>> management software to detect such condition and clean the the mirroring
>> before. This would lead all packets to the bridge to be dropped and break the
>> netowrk of other virtual machines.
>> 
>> To solve the issue, the patch does not drop packets when kernel fails to mirror
>> it, and only drop the redirected packets.
>> 
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thanks.
