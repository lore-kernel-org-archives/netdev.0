From: P@draigBrady.com
Subject: Re: [PATCH] Avoid gettimeofday when not needed
Date: Wed, 31 Mar 2004 13:22:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406AB7F6.6010805@draigBrady.com>
References: <200403311201.i2VC13D19579@zero.aec.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <200403311201.i2VC13D19579@zero.aec.at>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> This patch implements an optimization I proposed a long time=20
> ago. gettimeofday can be quite costly and it currently is=20
> on the fast path of every packet. Normally the packet time stamp
> is not needed (e.g. TCP doesn't use it), except for tcpdump
> and a few applications.

Will this work for apps that don't use a seperate syscall
to get the timestamp. Like CONFIG_PACKET_MMAP for e.g?

P=E1draig.
