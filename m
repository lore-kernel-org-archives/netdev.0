From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 23/39] Annotate hardware config module parameters in drivers/net/wireless/
Date: Fri, 02 Dec 2016 07:04:25 +0200
Message-ID: <8737i6syzq.fsf@kamboji.qca.qualcomm.com>
References: <148059537897.31612.9461043954611464597.stgit@warthog.procyon.org.uk>
        <148059556349.31612.1087071308520573382.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, gnomes@lxorguk.ukuu.org.uk,
        minyard@acm.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        linux-security-module@vger.kernel.org, keyrings@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148059556349.31612.1087071308520573382.stgit@warthog.procyon.org.uk>
        (David Howells's message of "Thu, 01 Dec 2016 12:32:43 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells <dhowells@redhat.com> writes:

> When the kernel is running in secure boot mode, we lock down the kernel to
> prevent userspace from modifying the running kernel image.  Whilst this
> includes prohibiting access to things like /dev/mem, it must also prevent
> access by means of configuring driver modules in such a way as to cause a
> device to access or modify the kernel image.
>
> To this end, annotate module_param* statements that refer to hardware
> configuration and indicate for future reference what type of parameter they
> specify.  The parameter parser in the core sees this information and can
> skip such parameters with an error message if the kernel is locked down.
> The module initialisation then runs as normal, but just sees whatever the
> default values for those parameters is.
>
> Note that we do still need to do the module initialisation because some
> drivers have viable defaults set in case parameters aren't specified and
> some drivers support automatic configuration (e.g. PNP or PCI) in addition
> to manually coded parameters.
>
> This patch annotates drivers in drivers/net/wireless/.
>
> Suggested-by: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Kalle Valo <kvalo@codeaurora.org>
> cc: linux-wireless@vger.kernel.org
> cc: netdev@vger.kernel.org
> ---
>
>  drivers/net/wireless/cisco/airo.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Via which tree are you planning to submit this, should I take it to
wireless-drivers or will someone else handle it? I didn't get the cover
letter so I have no idea.

-- 
Kalle Valo
