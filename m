From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] vhost: fix ubuf_info cleanup
Date: Tue, 11 Jun 2013 02:46:58 -0700 (PDT)
Message-ID: <20130611.024658.1499256804576895449.davem@davemloft.net>
References: <1370521145-9723-1-git-send-email-mst@redhat.com>
	<1370521145-9723-3-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tt.rantala@gmail.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1370521145-9723-3-git-send-email-mst@redhat.com>
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
Date: Thu, 6 Jun 2013 15:20:46 +0300

> vhost_net_clear_ubuf_info didn't clear ubuf_info
> after kfree, this could trigger double free.
> Fix this and simplify this code to make it more robust: make sure
> ubuf info is always freed through vhost_net_clear_ubuf_info.
> 
> Reported-by: Tommi Rantala <tt.rantala@gmail.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
