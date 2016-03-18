From: Venkatesh Srinivas via Virtualization
	<virtualization@lists.linux-foundation.org>
Subject: Re: [PATCH net-next] virtio_net: replace netdev_alloc_skb_ip_align()
	with napi_alloc_skb()
Date: Thu, 17 Mar 2016 18:01:23 -0700
Message-ID: <CAHdzE-_u35Kg1zck1KKCYhu5epx4vNtzE7UX41Bi85vsJ55ROw@mail.gmail.com>
References: <b436c3eb5d4c19e92184c27d89ec8118d6fd3f81.1458224603.git.pabeni@redhat.com>
Reply-To: Venkatesh Srinivas <venkateshs@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <b436c3eb5d4c19e92184c27d89ec8118d6fd3f81.1458224603.git.pabeni@redhat.com>
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

On Thu, Mar 17, 2016 at 7:44 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>
> This gives small but noticeable rx performance improvement (2-3%)
> and will allow exploiting future napi improvement.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

Worked in my tests, though the performance win was in the noise (+0.6%
- +1% bandwidth).
What tests did you see a 2-3% win on?

Do you think its worth modifying add_recvbuf_small() to use
napi_alloc_skb() when called from
Rx NAPI (virtnet_receive)?

Tested-by: Venkatesh Srinivas <venkateshs@google.com>

Thanks,
-- vs;
