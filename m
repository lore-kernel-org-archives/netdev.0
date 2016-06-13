From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v1 1/1] ipv4: Prevent malformed UFO fragments in
 ip_append_page
Date: Mon, 13 Jun 2016 21:27:16 +0200
Message-ID: <63247f00-968a-e77a-70e5-90301df64b84@stressinduktion.org>
References: <6A051441C8B95A448E49718A747690B901CA76C84F@gbplmail03.genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Steven Caron <steven.caron@genband.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6A051441C8B95A448E49718A747690B901CA76C84F@gbplmail03.genband.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13.06.2016 16:01, Steven Caron wrote:
> 
> As  the ip fragment offset field counts 8-byte chunks, non-final ip
> fragments must be multiples of 8 bytes of payload. Depending  on the
> mtu and ip option sizes, ip_append_page wasn't respecting this,
> notably when running NFS under UDP.
> 
> Signed-off-by: Steven Caron <steven.caron@genband.com>

Awesome!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
