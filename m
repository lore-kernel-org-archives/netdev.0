From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: define VSOCK_SS_LISTEN once only
Date: Sun, 01 Nov 2015 12:15:02 -0500 (EST)
Message-ID: <20151101.121502.1753196778636094034.davem@davemloft.net>
References: <1446119862-24369-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jhansen@vmware.com, virtualization@lists.linux-foundation.org
To: stefanha@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1446119862-24369-1-git-send-email-stefanha@redhat.com>
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

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Thu, 29 Oct 2015 11:57:42 +0000

> The SS_LISTEN socket state is defined by both af_vsock.c and
> vmci_transport.c.  This is risky since the value could be changed in one
> file and the other would be out of sync.
> 
> Rename from SS_LISTEN to VSOCK_SS_LISTEN since the constant is not part
> of enum socket_state (SS_CONNECTED, ...).  This way it is clear that the
> constant is vsock-specific.
> 
> The big text reflow in af_vsock.c was necessary to keep to the maximum
> line length.  Text is unchanged except for s/SS_LISTEN/VSOCK_SS_LISTEN/.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>

Applied to net-next, thanks.
