From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] virtio_net: enable napi for all possible queues
	during open
Date: Thu, 23 May 2013 00:11:23 -0700 (PDT)
Message-ID: <20130523.001123.1597846956917976677.davem@davemloft.net>
References: <1369202638-17660-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, sasha.levin@oracle.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1369202638-17660-1-git-send-email-jasowang@redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 22 May 2013 14:03:58 +0800

> Commit 55257d72bd1c51f25106350f4983ec19f62ed1fa (virtio-net: fill only rx
> queues which are being used) only does the napi enabling during open for
> curr_queue_pairs. This will break multiqueue receiving since napi of new queues
> were still disabled after changing the number of queues.
> 
> This patch fixes this by enabling napi for all possible queues during open.
> 
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks.
