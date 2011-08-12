From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/2] net: minor update to Documentation/networking/scaling.txt
Date: Fri, 12 Aug 2011 16:32:32 -0700
Message-ID: <4E45B810.3000501@hp.com>
References: <1312899648.5889.14.camel@gopher.nyc.corp.google.com> <4E418030.2010102@hp.com> <4E44752D.1080905@google.com> <4E4476CC.5050900@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, linux-doc@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4E4476CC.5050900@google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/11/2011 05:41 PM, Willem de Bruijn wrote:
> Incorporate last comments about hyperthreading, interrupt coalescing and
> the definition of cache domains into the network scaling document scaling.txt
>
> Signed-off-by: Willem de Bruijn<willemb@google.com>
>
> ---
>   Documentation/networking/scaling.txt |   23 +++++++++++++++--------
>   1 files changed, 15 insertions(+), 8 deletions(-)
>
> diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
> index 3da03c3..6197126 100644
> --- a/Documentation/networking/scaling.txt
> +++ b/Documentation/networking/scaling.txt
> @@ -52,7 +52,8 @@ module parameter for specifying the number of hardware queues to
>   configure. In the bnx2x driver, for instance, this parameter is called
>   num_queues. A typical RSS configuration would be to have one receive queue
>   for each CPU if the device supports enough queues, or otherwise at least
> -one for each cache domain at a particular cache level (L1, L2, etc.).
> +one for each memory domain, where a memory domain is a set of CPUs that
> +share a particular memory level (L1, L2, NUMA node, etc.).

I'd suggest simply "share a particular level in the memory hierarchy 
(Cache, NUMA node, etc)"  and that way you get away from people asking 
nitpicky questions about where cache hierarchy counting starts, and at 
what level caches might be shared :)

Apart from that, looks fine.

rick jones
