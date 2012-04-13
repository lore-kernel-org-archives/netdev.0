From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: struct ubuf_info callback type safety
Date: Fri, 13 Apr 2012 13:09:40 -0400 (EDT)
Message-ID: <20120413.130940.132638261191849442.davem@davemloft.net>
References: <20120409102402.GA5255@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	shemminger@vyatta.com, xma@us.ibm.com
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120409102402.GA5255@redhat.com>
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
Date: Mon, 9 Apr 2012 13:24:02 +0300

> The skb struct ubuf_info callback gets passed struct ubuf_info
> itself, not the arg value as the field name and the function signature
> seem to imply. Rename the arg field to ctx to match usage,
> add documentation and change the callback argument type
> to make usage clear and to have compiler check correctness.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks for fixing this Michael.
