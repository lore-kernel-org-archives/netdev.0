From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] tuntap: choose the txq based on rxq
Date: Mon, 29 Oct 2012 14:03:48 +0800
Message-ID: <508E1C44.9070405@redhat.com>
References: <1351488964-11109-1-git-send-email-jasowang@redhat.com> <1351488964-11109-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, maxk@qualcomm.com,
	haixiao@juniper.net, ernesto.martin@viasat.com,
	krkumar2@in.ibm.com, edumazet@google.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351488964-11109-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2012 01:35 PM, Jason Wang wrote:
> This patch implements a simple multiqueue flow steering policy - tx follows rx
> for tun/tap. The idea is simple, it just choose the txq based on which rxq it
> comes. The flow were identified through the rxhash of a skb, and the hash to
> queue mapping were recorded in a hlist with an ageing timer to retire the
> mapping. The mapping were created when tun receives packet from userspace, and
> was quired in .ndo_select_queue().
>
> I run co-current TCP_CRR test and didn't see any mapping manipulation helpers in
> perf top, so the overhead could be negelected.
>
> Signed-off-by: Jason Wang<jasowang@redhat.com>

Sorry, send the wrong patch, please ignore this patch.
