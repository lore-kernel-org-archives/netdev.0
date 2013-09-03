From: Christoph Lameter <cl@linux.com>
Subject: Re: [guv v2 04/31] net: Replace __get_cpu_var uses
Date: Tue, 3 Sep 2013 14:21:07 +0000
Message-ID: <00000140e432c014-26be929a-a2f1-4064-8147-0efcb5dc3bec-000000@email.amazonses.com>
References: <00000140bc5ef9df-d7f75909-a25e-4471-84b2-dfbec07117b0-000000@email.amazonses.com> <20130826204351.725357339@linux.com> <7435.1378157706@warthog.procyon.org.uk> <20130902.203355.117341085023152754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dhowells@redhat.com, tj@kernel.org, akpm@linuxfoundation.org,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org,
	srostedt@redhat.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130902.203355.117341085023152754.davem@davemloft.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Sep 2013, David Miller wrote:

> It really will cache pre-computed __thread pointer calculations across
> sched().

On x86 the compiler could use the segment prefix and then it may work.
