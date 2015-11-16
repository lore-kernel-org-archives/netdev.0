From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel 4.1 hang, apparently in __inet_lookup_established
Date: Mon, 16 Nov 2015 07:07:49 -0800
Message-ID: <1447686469.22599.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5726932.6r4XOZ2Km2@rofl>
	 <1443025879.29850.116.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56492A39.2060307@fastly.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick Schaaf <kernelorg@bof.de>, NETDEV <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Grant Zhang <gzhang@fastly.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56492A39.2060307@fastly.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-11-15 at 16:58 -0800, Grant Zhang wrote:
> Hi Patrick,
> 
> Have you tried the two patches Eric mentioned? One of my 4.1.11 server 
> just hanged with very similar stack trace and I am wondering whether the 
> aforementioned patches would help.
> 
> Thanks,

linux-4.1.12 definitely contains the fixes.

8ae3dfacdd82 inet: fix race in reqsk_queue_unlink()
31b8abd140ad inet: fix races in reqsk_queue_hash_req()

Please upgrade to 4.1.13 and you should be fine.

Thanks.
