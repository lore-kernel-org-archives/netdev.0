From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V6 0/8] introduce Hyper-V VM Socket(hv_sock)
Date: Sun, 14 Feb 2016 03:56:51 +0000
Message-ID: <6bc0872dc8244630a17698aa746a1b4e@HKXPR3004MB0088.064d.mgd.msft.net>
References: <1453801183-3187-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "davem@davemloft.net" <davem@davemloft.net>, "stephen@networkplumber.org"
 <stephen@networkplumber.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "apw@canonical.com" <apw@canonical.com>, "jasowang@redhat.com"
 <jasowang@redhat.com>, KY Srinivasan <kys@microsoft.com>,
 "vkuznets@redhat.com" <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1453801183-3187-1-git-send-email-decui@microsoft.com>
Content-Language: en-US
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

> From: devel [mailto:driverdev-devel-bounces@linuxdriverproject.org] On Behalf
> Of Dexuan Cui
> Sent: Tuesday, January 26, 2016 17:40
> ...
> Dexuan Cui (8):
>   Drivers: hv: vmbus: add a helper function to set a channel's pending
>     send size
>   Drivers: hv: vmbus: define the new offer type for Hyper-V socket
>     (hvsock)
>   Drivers: hv: vmbus: vmbus_sendpacket_ctl: hvsock: avoid unnecessary
>     signaling
>   Drivers: hv: vmbus: define a new VMBus message type for hvsock
>   Drivers: hv: vmbus: add a hvsock flag in struct hv_driver
>   Drivers: hv: vmbus: add a per-channel rescind callback
>   Drivers: hv: vmbus: add an API vmbus_hvsock_device_unregister()
>   hvsock: introduce Hyper-V Socket feature

Hi David,
Greg has accepted all my VMBus driver side's patches.
I'm going to post the net/hv_sock/ patch now.

I know I should rebase my patch to the net-next tree, but net-next hasn't
contained my VMBus driver side's patches, which are a prerequisite of my
net/hv_sock/ patch.

It looks I have to wait before you merge net-next with Greg's tree, or
with the mainline (after Greg pushes the changes to the mainline)?
If so, may I know when the next merge will be happening (so I don't need
to check net-next every day :-) ) ?

Thanks,
-- Dexuan
