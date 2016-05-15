From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v11 net-next 0/1] introduce Hyper-V VM Sockets(hv_sock)
Date: Sun, 15 May 2016 13:16:06 -0400 (EDT)
Message-ID: <20160515.131606.1794366975297405715.davem@davemloft.net>
References: <1463331162-6679-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, gregkh@linuxfoundation.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, joe@perches.com, netdev@vger.kernel.org,
 apw@canonical.com, devel@linuxdriverproject.org, haiyangz@microsoft.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1463331162-6679-1-git-send-email-decui@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Sun, 15 May 2016 09:52:42 -0700

> Changes since v10
> 
> 1) add module params: send_ring_page, recv_ring_page. They can be used to
> enlarge the ringbuffer size to get better performance, e.g.,
> # modprobe hv_sock  recv_ring_page=16 send_ring_page=16
> By default, recv_ring_page is 3 and send_ring_page is 2.
> 
> 2) add module param max_socket_number (the default is 1024).
> A user can enlarge the number to create more than 1024 hv_sock sockets.
> By default, 1024 sockets take about 1024 * (3+2+1+1) * 4KB = 28M bytes.
> (Here 1+1 means 1 page for send/recv buffers per connection, respectively.)

This is papering around my objections, and create module parameters which
I am fundamentally against.

You're making the facility unusable by default, just to work around my
memory consumption concerns.

What will end up happening is that everyone will simply increase the
values.

You're not really addressing the core issue, and I will be ignoring you
future submissions of this change until you do.
