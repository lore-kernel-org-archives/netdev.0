From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] virtio_net: set multicast filter list to host
Date: Tue, 10 Dec 2013 22:28:55 -0500 (EST)
Message-ID: <20131210.222855.1811117066430551865.davem@davemloft.net>
References: <20131209161632.5ac96e5a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	mst@redhat.com
To: stephen@networkplumber.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131209161632.5ac96e5a@nehalam.linuxnetplumber.net>
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

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 9 Dec 2013 16:16:32 -0800

> The virtio_net driver never sends the multicast address list to
> the host. This is because send command takes a pointer to scatter list
> to send but only inserts that one entry into the outgoing scatter list.
> 
> This bug has been there since:
> commit f565a7c259d71cc186753653d978c646d2354b36
> Author: Alex Williamson <alex.williamson@hp.com>
> Date:   Wed Feb 4 09:02:45 2009 +0000
> 
>     virtio_net: Add a MAC filter table
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

This seems to still be under discussion so I'll hold off on this
one for now.

Thanks.
