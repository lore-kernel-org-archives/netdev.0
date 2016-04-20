From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: Only check error on skb_recv_datagram when skb
	is NULL
Date: Tue, 19 Apr 2016 20:42:22 -0400 (EDT)
Message-ID: <20160419.204222.1756702325926543286.davem@davemloft.net>
References: <1461049132-59927-1-git-send-email-jhansen@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: jhansen@vmware.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1461049132-59927-1-git-send-email-jhansen@vmware.com>
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

From: Jorgen Hansen <jhansen@vmware.com>
Date: Mon, 18 Apr 2016 23:58:52 -0700

> If skb_recv_datagram returns an skb, we should ignore the err
> value returned. Otherwise, datagram receives will return EAGAIN
> when they have to wait for a datagram.
> 
> Acked-by: Adit Ranadive <aditr@vmware.com>
> Signed-off-by: Jorgen Hansen <jhansen@vmware.com>

Applied.
