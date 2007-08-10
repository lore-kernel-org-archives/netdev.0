From: "md ayyaz" <md.ayyaz@gmail.com>
Subject: Fwd: bug in kernel 2.6.20.9 in ipv6 dest opt <help>
Date: Fri, 10 Aug 2007 12:34:27 +0530
Message-ID: <df1706540708100004r78b3bbaau1aee5e613172b48f@mail.gmail.com>
References: <df1706540708092335h1c8ad61dq6ed8f11e01d0190e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:7664 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754974AbXHJHE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 03:04:28 -0400
Received: by wa-out-1112.google.com with SMTP id v27so816735wah
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 00:04:27 -0700 (PDT)
In-Reply-To: <df1706540708092335h1c8ad61dq6ed8f11e01d0190e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---------- Forwarded message ----------
From: md ayyaz <md.ayyaz@gmail.com>
Date: Aug 10, 2007 12:05 PM
Subject: bug in kernel 2.6.20.9 in ipv6 dest opt <help>
To: yoshfuji@linux-ipv6.org


Hi ,
i am working on mobile ipv6 protocol , so what happens whenver i pass
a ipv6 packet with destination option in it , it doesnt parse it
correctly in extension header parsing for dest option and hence
returns -1 as an error back so packet gets dropped in ip layer , along
with this if i send ipv6-ipv6 tunnel packet it shows slab corruption
in logs ,( i had put some debug messages)

please reply as soon as possible i will be greatly thankfull for the help

Aug  1 16:18:12 localhost kernel: Recived IPv6 packet with next hdr as 17 from
3ffe:0300:0068:0218:f3ff:fed9:8914:f521600001
Aug  1 16:18:12 localhost kernel:  packet Len : 173 nxt Hdr : 17 skb:213
Aug  1 16:18:13 localhost kernel: Recived IPv6 packet with next hdr as 17 from
3ffe:0300:0068:0218:f3ff:fed9:8914:f521600001
Aug  1 16:18:13 localhost kernel:  packet Len : 173 nxt Hdr : 17 skb:213
Aug  1 16:18:14 localhost kernel: Recived IPv6 packet with next hdr as 58 from
fe80:0000:0000:0218:f3ff:feda:83cb:f521600001
Aug  1 16:18:14 localhost kernel:  packet Len : 64 nxt Hdr : 58 skb:104
Aug  1 16:18:16 localhost kernel: Recived IPv6 packet with next hdr as 58 from
fe80:0000:0000:0218:f3ff:feda:83cb:f521600001
Aug  1 16:18:16 localhost kernel:  packet Len : 24 nxt Hdr : 58 skb:64
Aug  1 16:18:18 localhost kernel: Recived IPv6 packet with next hdr as 58 from
fe80:0000:0000:0218:f3ff:feda:83cb:f521600001
Aug  1 16:18:18 localhost kernel:  packet Len : 64 nxt Hdr : 58 skb:104
Aug  1 16:18:21 localhost kernel: Recived IPv6 packet with next hdr as 58 from
fe80:0000:0000:0218:f3ff:feda:83cb:f521600001
Aug  1 16:18:21 localhost kernel:  packet Len : 32 nxt Hdr : 58 skb:72
Aug  1 16:18:24 localhost kernel: Recived IPv6 packet with next hdr as 41 from
3ffe:0300:0068:020c:29ff:fea2:b14c:f521600001
Aug  1 16:18:24 localhost kernel:  packet Len : 140 nxt Hdr : 41 skb:180
Aug  1 16:18:24 localhost kernel: Slab corruption: start=f50b1dac, len=176
Aug  1 16:18:24 localhost kernel: Redzone: 0x5a2cf071/0x5a2cf071.
Aug  1 16:18:24 localhost kernel: Last user:
[<c055d930>](kfree_skbmem+0x63/0x66)
   Aug  1 16:18:24 localhost kernel: 090: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
   6a 6b 6b 6b
   Aug  1 16:18:24 localhost kernel: Single bit error detected. Probably bad
   RAM.
   Aug  1 16:18:24 localhost kernel: Run memtest86+ or a similar memory test
   tool.
   Aug  1 16:18:24 localhost kernel: Prev obj: start=f50b1cf0, len=176
   Aug  1 16:18:24 localhost kernel: Redzone: 0x170fc2a5/0x170fc2a5.
   Aug  1 16:18:24 localhost kernel: Last user:
   [<c055e041>](__alloc_skb+0x2c/0xfd)
   Aug  1 16:18:24 localhost kernel: 000: 00 00 00 00 00 00 00 00 00 00 00 00
   00 00 00 00
   Aug  1 16:18:24 localhost kernel: 010: 00 00 00 00 00 60 21 f5 00 00 00 00
   00 00 00 00
   Aug  1 16:18:24 localhost kernel: Next obj: start=f50b1e68, len=176
   Aug  1 16:18:24 localhost kernel: Redzone: 0x170fc2a5/0x170fc2a5.
   Aug  1 16:18:24 localhost kernel: Last user:
   [<c055e041>](__alloc_skb+0x2c/0xfd)
   Aug  1 16:18:24 localhost kernel: 000: 00 00 00 00 00 00 00 00 00 00 00 00
   00 00 00 00
   Aug  1 16:18:24 localhost kernel: 010: 00 00 00 00 00 60 21 f5 00 00 00 00
   00 00 00 00
   Aug  1 16:18:26 localhost kernel: Recived IPv6 packet with next hdr as 58
   from fe80:0000:0000:0218:f3ff:feda:83cb:f521600001
   Aug  1 16:18:26 localhost kernel:  packet Len : 64 nxt Hdr : 58 skb:104
   Aug  1 16:18:35 localhost kernel: Recived IPv6 packet with next hdr as 58
   from fe80:0000:0000:0218:f3ff:feda:83cb:f521600001
   Aug  1 16:18:35 localhost kernel:  packet Len : 64 nxt Hdr : 58 skb:104
   Aug  1 16:18:37 localhost kernel: Recived IPv6 packet with next hdr as 41
   from 3ffe:0300:0068:020c:29ff:fea2:b14c:f521600001
   Aug  1 16:18:37 localhost kernel:  packet Len : 140 nxt Hdr : 41 skb:180
   Aug  1 16:18:37 localhost kernel: Slab corruption: start=f50ba4dc, len=176
   Aug  1 16:18:37 localhost kernel: Redzone: 0x5a2cf071/0x5a2cf071.
   Aug  1 16:18:37 localhost kernel: Last user:
   [<c055d930>](kfree_skbmem+0x63/0x66)
   Aug  1 16:18:37 localhost kernel: 090: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
   6a 6b 6b 6b
   Aug  1 16:18:37 localhost kernel: Single bit error detected. Probably bad
   RAM.
   Aug  1 16:18:37 localhost kernel: Run memtest86+ or a similar memory test
   tool.
   Aug  1 16:18:37 localhost kernel: Prev obj: start=f50ba420, len=176
   Aug  1 16:18:37 localhost kernel: Redzone: 0x170fc2a5/0x170fc2a5.
   Aug  1 16:18:37 localhost kernel: Last user:
   [<c055e041>](__alloc_skb+0x2c/0xfd)
   Aug  1 16:18:37 localhost kernel: 000: 00 00 00 00 00 00 00 00 00 00 00 00
   00 00 00 00
   Aug  1 16:18:37 localhost kernel: 010: 00 00 00 00 00 60 21 f5 00 00 00 00
   00 00 00 00
   Aug  1 16:18:37 localhost kernel: Next obj: start=f50ba598, len=176
   Aug  1 16:18:37 localhost kernel: Redzone: 0x170fc2a5/0x170fc2a5.
   Aug  1 16:18:37 localhost kernel: Last user:
   [<c055e041>](__alloc_skb+0x2c/0xfd)
   Aug  1 16:18:37 localhost kernel: 000: 00 00 00 00 00 00 00 00 00 00 00 00
   00 00 00 00
   Aug  1 16:18:37 localhost kernel: 010: 00 00 00 00 00 00 f6 f7 00 00 00 00
   00 00 00 00
