From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 03/33] nf_conntrack_gre: nf_ct_gre_keymap_flush() fixlet
Date: Tue, 09 Sep 2008 07:39:59 +0200
Message-ID: <48C60C2F.8020503@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-3-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1220842990-30500-3-git-send-email-adobriyan@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> It does "kfree(list_head)" which looks wrong because entity that was
> allocated is definitely not list_head.
> 
> However, this all works because list_head is first item in
> struct nf_ct_gre_keymap .

The first three patches are already in Linus' tree.
