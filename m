From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: unbreak cusmed packet for small buffer XDP
Date: Thu, 6 Jul 2017 03:07:07 +0300
Message-ID: <20170706030356-mutt-send-email-mst@kernel.org>
References: <20170628050057-mutt-send-email-mst@kernel.org>
	<7068053c-50da-6779-5ff2-6588e01e616d@redhat.com>
	<20170628051555-mutt-send-email-mst@kernel.org>
	<69907228-fc1b-175f-f6cd-7ac332e318be@redhat.com>
	<20170628063033-mutt-send-email-mst@kernel.org>
	<51f4c402-6a02-9bad-6dab-563ca72f431a@redhat.com>
	<20170628065126-mutt-send-email-mst@kernel.org>
	<a7e457d5-88c4-745d-5189-18a5f13797dc@redhat.com>
	<20170703195752-mutt-send-email-mst@kernel.org>
	<4de0c8e7-a9b6-7477-691a-a2ed0f317106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <4de0c8e7-a9b6-7477-691a-a2ed0f317106@redhat.com>
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

On Tue, Jul 04, 2017 at 08:20:00PM +0800, Jason Wang wrote:
> > IIUC XDP generally refuses to attach if checksum offload
> > is enabled.
> 
> Any reason to do this? (Looks like I don't see any code for this)

Some of it was covered here
https://www.mail-archive.com/netdev@vger.kernel.org/msg162577.html

-- 
MST
