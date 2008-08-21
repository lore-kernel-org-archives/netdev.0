From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Thu, 21 Aug 2008 19:06:37 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0808211903000.20596@fbirervta.pbzchgretzou.qr>
References: <20080821220432.GT31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080821220432.GT31136@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2008-08-21 18:04, adobriyan@gmail.com wrote:

>Make untracked conntrack per-netns.

Why? It does not store any useful information per se, it is
merely used to add a third type of ct, iow:

(a) ct==NULL
(b) ct!=NULL
(c) ct==&untracked

mmap(2)'s return value for example has something similar:

(a) mmap(...)==NULL
(b) mmap(...)==MMAP_FAILED
(c) otherwise

The untracked ct is a singleton, and should stay one, unless
there are further reasons not to do so.

