From: Francis Moreau <francis.moro@gmail.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct
Date: Fri, 30 Oct 2009 13:33:56 +0100
Message-ID: <38b2ab8a0910300533l4bbc9d3cj8812fe38726c8278@mail.gmail.com>
References: <38b2ab8a0909290109m3f82c161j4fb0f1266152877e@mail.gmail.com>
	 <4AC1D0F5.4050709@gmail.com>
	 <38b2ab8a0910300144i7a3c190fi9aa3d079c9cdb754@mail.gmail.com>
	 <4AEACD88.8080108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756825AbZJ3Mdy@vger.kernel.org>
In-Reply-To: <4AEACD88.8080108@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2009 at 12:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> This oops occurring again and again with SUNRPC finally gave me the right pointer.
>
> David, we added two years ago memory accounting to UDP, and this changed
> requirements about calling skb_free_datagram() in the right context.
>
> I wish we had an ASSERT_SOCK_LOCKED() debugging facility :(
>
> Francis, would you please test following patch ?

I'm applying it and testing it during a couple of days and see if
something wrong still happens.

Since I have no specific test case, I'll report if this oops happen
again after a couple of days (probably on next Wednesday).

-- 
Francis
