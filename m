From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: integer overflow in ip_idents_reserve
Date: Tue, 16 Dec 2014 13:47:40 -0800
Message-ID: <1418766460.9773.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5490A1F8.6020207@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andrey Ryabinin <a.ryabinin@samsung.com>,
	Dave Jones <davej@redhat.com>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5490A1F8.6020207@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-12-16 at 16:19 -0500, Sasha Levin wrote:
> Hi Eric,
> 
> While fuzzing with trinity on a -next kernel with the undefined behaviour
> sanitizer path, I've observed the following warning in code which was
> introduced in 04ca6973f7 ("ip: make IP identifiers less predictable"):

This is a false positive.

We don't really care of the value if (now - old) is too big :

No packet was sent recently, so IP ID being X or Y is not a concern.
