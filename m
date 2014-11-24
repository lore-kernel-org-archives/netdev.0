From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: Re: [PATCH] xen-netback: do not report success if xenvif_alloc()
 fails
Date: Mon, 24 Nov 2014 13:44:58 +0300
Message-ID: <54730C2A.3020108@ispras.ru>
References: <1416610588-19816-1-git-send-email-khoroshilov@ispras.ru> <20141124100053.GC30053@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141124100053.GC30053@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24.11.2014 13:00, Wei Liu wrote:
> On Sat, Nov 22, 2014 at 01:56:28AM +0300, Alexey Khoroshilov wrote:
>> If xenvif_alloc() failes, netback_probe() reports success as well as
>> "online" uevent is emitted. It does not make any sense, but it just
> Sorry, I don't follow. KOBJ_ONLINE event is not emitted in the event of
> xenvif_alloc fails, is it?
Yes, you are right.
>
>> misleads users.
>>
>> The patch implements propagation of error code if xenvif creation fails.
>>
> This patch not only implements propagation of error code when xenvif
> creation fails, but also when xenbus_scanf fails. You can simply write
> "This patch implements propagation of error code for
> backend_create_xenvif".
>
> The rest of this patch looks good to me. Can you rewrite commit message
> and resubmit, thanks.
Ok.

--
Thank you,
Alexey
