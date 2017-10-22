From: Pekka Enberg <penberg@iki.fi>
Subject: Re: [PATCH 1/2] slab, slub, slob: add slab_flags_t
Date: Sun, 22 Oct 2017 09:40:14 +0300
Message-ID: <f4a10428-c35c-d1d4-1816-5175f88b8962@iki.fi>
References: <20171021100225.GA22428@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org,
        rientjes@google.com, iamjoonsoo.kim@lge.com,
        ecryptfs@vger.kernel.org, linux-xfs@vger.kernel.org,
        kasan-dev@googlegroups.com, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:49855 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751112AbdJVGkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 02:40:18 -0400
In-Reply-To: <20171021100225.GA22428@avx2>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 21/10/2017 13.02, Alexey Dobriyan wrote:
> Add sparse-checked slab_flags_t for struct kmem_cache::flags
> (SLAB_POISON, etc).
> 
> SLAB is bloated temporarily by switching to "unsigned long",
> but only temporarily.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Acked-by: Pekka Enberg <penberg@kernel.org>
