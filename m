From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v3 5/5] virtio-net: initial rx sysfs support,
	export mergeable rx buffer size
Date: Thu, 16 Jan 2014 08:33:38 -0800
Message-ID: <CANJ5vPJZACr=y3uRv0Rnq330jQCi4dLvhyQd88ascZjBg_jfUw@mail.gmail.com>
References: <1389865126-26225-1-git-send-email-mwdalton@google.com>
	<1389865126-26225-5-git-send-email-mwdalton@google.com>
	<20140116115340.GC29061@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140116115340.GC29061@redhat.com>
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

Hi Michael,

On Thu, Jan 16, 2014 at 3:53 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> Hmm this adds overhead just to prevent sysfs from getting wrong value.
> Can't sysfs simply disable softirq while it's reading the value?
Yes I think this would work, we could call napi_disable(), read the
average packet length from the receive_queue, and then call
virtnet_napi_enable(). That would eliminate the need for the seqcount.

Best,

Mike
