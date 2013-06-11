From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] vhost: check owner before we overwrite ubuf_info
Date: Tue, 11 Jun 2013 02:46:52 -0700 (PDT)
Message-ID: <20130611.024652.352722242220532694.davem@davemloft.net>
References: <1370521145-9723-1-git-send-email-mst@redhat.com>
	<1370521145-9723-2-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tt.rantala@gmail.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1370521145-9723-2-git-send-email-mst@redhat.com>
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
Date: Thu, 6 Jun 2013 15:20:39 +0300

> If device has an owner, we shouldn't touch ubuf_info
> since it might be in use.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
