From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: locking issue in vhost_net_set_backend
Date: Tue, 16 Mar 2010 15:01:51 +0100
Message-ID: <4B9F8F4F.7010103@gmail.com>
References: <4B9F8E7F.7070709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B9F8E7F.7070709@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/16/2010 02:58 PM, Jiri Slaby wrote:
> I don't see how the lock is unlocked on the error paths and as it is not
> on none of the them maybe I'm missing something?

And there is one more issue in vhost_set_vring, several returns from 
VHOST_SET_VRING_KICK, VHOST_SET_VRING_CALL, VHOST_SET_VRING_ERR with the 
vq->mutex held.

-- 
js
