From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: Don't dec ack backlog twice for rejected
	connections
Date: Tue, 27 Sep 2016 07:59:56 -0400 (EDT)
Message-ID: <20160927.075956.93420092875299733.davem@davemloft.net>
References: <1474959593-15311-1-git-send-email-jhansen@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, stefanha@redhat.com,
	gregkh@linuxfoundation.org
To: jhansen@vmware.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1474959593-15311-1-git-send-email-jhansen@vmware.com>
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
Date: Mon, 26 Sep 2016 23:59:53 -0700

> If a pending socket is marked as rejected, we will decrease the
> sk_ack_backlog twice. So don't decrement it for rejected sockets
> in vsock_pending_work().
> 
> Testing of the rejected socket path was done through code
> modifications.
> 
> Reported-by: Stefan Hajnoczi <stefanha@redhat.com>
> Signed-off-by: Jorgen Hansen <jhansen@vmware.com>
> Reviewed-by: Adit Ranadive <aditr@vmware.com>
> Reviewed-by: Aditya Sarwade <asarwade@vmware.com>

Applied, thanks.
