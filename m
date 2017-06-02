From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] virtio_net: lower limit on buffer size
Date: Fri, 2 Jun 2017 12:34:57 +0300
Message-ID: <3dd90d56-7110-bb9e-0b7f-4c8a8003a57f@cogentembedded.com>
References: <1496361148-4603-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	Mikulas Patocka <mpatocka@redhat.com>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1496361148-4603-1-git-send-email-mst@redhat.com>
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

Hello!

On 6/2/2017 2:56 AM, Michael S. Tsirkin wrote:

> commit d85b758f72b0 "virtio_net: fix support for small rings"

    Commit d85b758f72b0 ("virtio_net: fix support for small rings")

> was supposed to increase the buffer size for small rings
> but had an unintentional side effect of decreasing
> it for large rings. This seems to break some setups -
> it's not yet clear why, but increasing buffer size
> back to what it was before helps.
>
> Fixes: d85b758f72b0 "virtio_net: fix support for small rings"

Fixes: d85b758f72b0 ("virtio_net: fix support for small rings")

> Reported-by: Mikulas Patocka <mpatocka@redhat.com>
> Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
[...]

MBR, Sergei
