From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: don't xt_jumpstack_alloc twice in xt_register_table
Date: Mon, 31 May 2010 16:34:32 +0200
Message-ID: <4C03C8F8.8050602@trash.net>
References: <1275303998-2435-1-git-send-email-dfeng@redhat.com> <alpine.LSU.2.01.1005311350580.31799@obet.zrqbmnf.qr> <alpine.LSU.2.01.1005311519160.25402@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Xiaotian Feng <dfeng@redhat.com>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1005311519160.25402@obet.zrqbmnf.qr>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Monday 2010-05-31 13:51, Jan Engelhardt wrote:
>> On Monday 2010-05-31 13:06, Xiaotian Feng wrote:
>>
>>> In xt_register_table, xt_jumpstack_alloc is called first, later
>>> xt_replace_table is used. But in xt_replace_table, xt_jumpstack_alloc
>>> will be used again. Then the memory allocated by previous xt_jumpstack_alloc
>>> will be leaked. We can simply remove the previous xt_jumpstack_alloc because
>>> there aren't any users of newinfo between xt_jumpstack_alloc and
>>> xt_replace_table.
>> Indeed that seems to be so.
> 
> Acked-By: Jan Engelhardt <jengelh@medozas.de>

Applied, thanks everyone.
