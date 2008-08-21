From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_conntrack_gre: more locking around keymap list
Date: Thu, 21 Aug 2008 13:32:22 +0200
Message-ID: <48AD5246.7050905@trash.net>
References: <20080820205451.GA16405@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080820205451.GA16405@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

adobriyan@gmail.com wrote:
> gre_keymap_list should be protected in all places.
> (unless I'm misreading something)

Agreed, I don't see a reason why it wouldn't need the lock.

Applied, thanks. I'll also push this one to -stable.
