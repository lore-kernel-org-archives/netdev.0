From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [net-next RFC V5 3/5] virtio: intorduce an API to set affinity
	for a virtqueue
Date: Mon, 30 Jul 2012 08:27:54 +0200
Message-ID: <5016296A.5070809@redhat.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<1341484194-8108-4-git-send-email-jasowang@redhat.com>
	<5012A7D3.4040800@redhat.com> <20120729204030.GB13802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, mashirle@us.ibm.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120729204030.GB13802@redhat.com>
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

Il 29/07/2012 22:40, Michael S. Tsirkin ha scritto:
>> > Did you set the affinity manually in your experiments, or perhaps there
>> > is a difference between scsi and networking... (interrupt mitigation?)
> 
> You need to run irqbalancer in guest to make it actually work. Do you?

Yes, of course, now on to debugging that one.  I just wanted to ask
before the weekend if I was missing something as obvious as that.

Paolo
