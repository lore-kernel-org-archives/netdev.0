From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 01/24] rxrpc: Fix processing of
 authenticated/encrypted jumbo packets
Date: Tue, 5 Jul 2016 20:55:09 +0300
Message-ID: <3303be0f-af5a-282a-e7d6-bf16a4aee2e1@cogentembedded.com>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
 <146772433840.21657.17138888082363167022.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146772433840.21657.17138888082363167022.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07/05/2016 04:12 PM, David Howells wrote:

> When a jumbo packet is being split up and processed, the crypto checksum
> for each split-out packet is in the jumbo header and needs placing in the
> reconstructed packet header.
>
> When commit 0d12f8a4027d021c9cc942f09f38d28288020c5d moved to keeping the

    scripts/checkpatch.pl now enforces the common commit citing style as for 
the Fixes: tag and the patch description, you need to specify the summary too.

> stored copy of the packet header in host byte order, this reconstruction
> was missed.
>
> Found with sparse with CF=-D__CHECK_ENDIAN__:
>
>     ../net/rxrpc/input.c:479:33: warning: incorrect type in assignment (different base types)
>     ../net/rxrpc/input.c:479:33:    expected unsigned short [unsigned] [usertype] _rsvd
>     ../net/rxrpc/input.c:479:33:    got restricted __be16 [addressable] [usertype] _rsvd
>
> Signed-off-by: David Howells <dhowells@redhat.com>
[...]

MBR, Sergei
