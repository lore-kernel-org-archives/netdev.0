From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: don't forget to free sk_filter
Date: Wed, 06 Nov 2013 11:28:18 -0800
Message-ID: <1383766098.21999.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383753106-26978-1-git-send-email-avagin@openvz.org>
	 <527A9638.4020404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Vagin <avagin@openvz.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	stable@vger.kernel.org.#.3.12
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <527A9638.4020404@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-11-06 at 20:19 +0100, Daniel Borkmann wrote:

> When you send v2 with Alexei's feedback, please also be more specific
> in your subject like "net: x86: bpf: don't forget to free sk_filter"
> or the like. Also it's enough to say 'This memory leak was introduced
> by commit d45ed4a4e3 ("net: fix unsafe set_memory_rw from softirq")'
> instead of copying the whole log. Anyways, for v2 with feedback included
> then:

Actually, the new way [1] of doing this would be to use the 'Fixes:' tag
as in :

Fixes: <12 digits SHA1> ("net: fix unsafe set_memory_rw from softirq")

[1] As discussed at last Kernel Summit

Example in 

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6920a1bd037374a632d585de127b6f945199dcb8
