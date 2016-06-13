From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 1/1] ipv4: Prevent malformed UFO fragments in
 ip_append_page
Date: Mon, 13 Jun 2016 08:16:43 -0700
Message-ID: <1465831003.7945.161.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6A051441C8B95A448E49718A747690B901CA76C84F@gbplmail03.genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Steven Caron <steven.caron@genband.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6A051441C8B95A448E49718A747690B901CA76C84F@gbplmail03.genband.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-06-13 at 14:01 +0000, Steven Caron wrote:
> As  the ip fragment offset field counts 8-byte chunks, non-final ip
> fragments must be multiples of 8 bytes of payload. Depending  on the
> mtu and ip option sizes, ip_append_page wasn't respecting this,
> notably when running NFS under UDP.
> 
> Signed-off-by: Steven Caron <steven.caron@genband.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
