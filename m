From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH v2] virtio-net: free bufs correctly on invalid packet
	length
Date: Fri, 6 Dec 2013 15:32:48 -0800
Message-ID: <CANJ5vPJp+6NyeT+bbfGSS0TS+Em4Qx3GTb3a2uTrs5jAAPgeBw@mail.gmail.com>
References: <1386278045-23542-1-git-send-email-mwdalton@google.com>
	<20131206.163235.687717622324552173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrey Vagin <avagin@openvz.org>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131206.163235.687717622324552173.davem@davemloft.net>
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

Hi David,

This patch fixes a bug introduced by 2613af0ed18a ("virtio_net:
migrate mergeable rx buffers to page frag allocators"). The bug
is present in both net-next and net. Thanks

Best,

Mike

On Fri, Dec 6, 2013 at 1:32 PM, David Miller <davem@davemloft.net> wrote:
> From: Michael Dalton <mwdalton@google.com>
> Date: Thu,  5 Dec 2013 13:14:05 -0800
>
>> When a packet with invalid length arrives, ensure that the packet
>> is freed correctly if mergeable packet buffers and big packets
>> (GUEST_TSO4) are both enabled.
>>
>> Signed-off-by: Michael Dalton <mwdalton@google.com>
>
> Applied, is this needed for -stable?
