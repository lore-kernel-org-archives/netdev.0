From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [net-next RFC PATCH 2/5] tuntap: simple flow director support
Date: Mon, 5 Dec 2011 10:38:12 +0000
Message-ID: <CAJSP0QX+MSXhzJ9QWYa_uNqb6uRMmD8cRYVR94YP8j0otL7t_A@mail.gmail.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085857.6116.99252.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, bhutchings@solarflare.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111205085857.6116.99252.stgit@dhcp-8-146.nay.redhat.com>
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

On Mon, Dec 5, 2011 at 8:58 AM, Jason Wang <jasowang@redhat.com> wrote:
> This patch adds a simple flow director to tun/tap device. It is just a
> page that contains the hash to queue mapping which could be changed by
> user-space. The backend (tap/macvtap) would query this table to get
> the desired queue of a packets when it send packets to userspace.
>
> The page address were set through a new kind of ioctl - TUNSETFD and
> were pinned until device exit or another new page were specified.

Please use "flow" or "fdir" instead of "fd" in the ioctl and code.
"fd" reminds of file descriptor.  The ixgbe driver uses "fdir".

Stefan
