From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Increase snd/rcv buffers in pppoe
Date: Sun, 22 Feb 2004 23:26:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040222232601.481b8c57.davem@redhat.com>
References: <20040222234750.GA78924@colin2.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20040222234750.GA78924@colin2.muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 23 Feb 2004 00:47:50 +0100
Andi Kleen <ak@muc.de> wrote:

> I noticed that a 64bit kernel only downloads half as fast over a PPPoE DSL
> connection than a 32bit kernel on the same hardware. The reason seems
> to be that PPPoE uses the default 64K snd/rcv buffers at socket creation.
> The bigger sk_buff header size on the 64bit kernel pushed
> the buffer into being too small and preventing good throughput.

I have no problem with this, but hey while we're at it why not do the same
for the core defaults instead?  I see no real harm in this at all as it's
not a pppoe specific issue.

What say you Andi?
