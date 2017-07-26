From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH net] Revert "vhost: cache used event for better
 performance"
Date: Wed, 26 Jul 2017 12:53:38 +0200
Message-ID: <da300d74-ca7a-a636-0ed6-6aa78e6a5510@de.ibm.com>
References: <1501056197-3368-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501056197-3368-1-git-send-email-jasowang@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/26/2017 10:03 AM, Jason Wang wrote:
> This reverts commit 809ecb9bca6a9424ccd392d67e368160f8b76c92. Since it
> was reported to break vhost_net. We want to cache used event and use
> it to check for notification. We try to valid cached used event by
> checking whether or not it was ahead of new, but this is not correct
> all the time, it could be stale and there's no way to know about this.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

This would then qualify for stable ?
