From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Re: [PATCH 00/10] Netfilter fixes for net
Date: Fri, 13 Nov 2015 12:58:38 -0500
Message-ID: <CA+5PVA7bbnn+29+pc-JwXDUtNn36Eab0K7U1hOY09hf3T-7q1Q@mail.gmail.com>
References: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 11, 2015 at 12:33 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> Jozsef Kadlecsik (3):
>       netfilter: ipset: Fix extension alignment
>       netfilter: ipset: Fix hash:* type expiration
>       netfilter: ipset: Fix hash type expire: release empty hash bucket block

Should these three go to stable?  We've had reports in Fedora about
ipset crashing on e.g. ARM architectures with 4.2.y kernels.  If not
all three, then perhaps just the alignment fix?

josh
