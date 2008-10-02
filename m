From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 7/6] netns ct: final netns tweaks
Date: Thu, 02 Oct 2008 10:11:22 +0200
Message-ID: <48E4822A.4070302@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net> <20080909073245.GA7307@x200.localdomain> <48C62B1C.7070104@trash.net> <20080913105509.GG7440@x200.localdomain> <20080926235901.GA10489@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080926235901.GA10489@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Add init_net checks to not remove kmem_caches twice and so on.
>
> Refactor functions to split code which should be executed only for
> init_net into one place.
>
> ip_ct_attach and ip_ct_destroy assignments remain separate, because
> they're separate stages in setup and teardown.
>
> NOTE: NOTRACK code is in for-every-net part. It will be made per-netns
> after we decidce how to do it correctly.

Also applied. thanks.

