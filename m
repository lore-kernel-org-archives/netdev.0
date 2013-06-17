From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 0/2] Low latency Socket support
Date: Mon, 17 Jun 2013 14:31:26 +0300
Message-ID: <51BEF38E.1060503@mellanox.com>
References: <1371466703-3370-1-git-send-email-amirv@mellanox.com> <51BEF19C.5050908@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Amir Ancel <amira@mellanox.com>,
	"Yevgeny Petrilin" <yevgenyp@mellanox.com>,
	Yaniv Saar <ysaar@mellanox.com>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:56299 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932390Ab3FQLck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 07:32:40 -0400
In-Reply-To: <51BEF19C.5050908@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/06/2013 14:23, Eliezer Tamir wrote:
> On 17/06/2013 13:58, Amir Vadai wrote:
>> Hi Dave,
>>
>> Please pull those 2 patches, which add support in Low Latency Socket
>> (LLS) to
>> mlx4_en.
>>
>> Thanks,
>> Amir
> 
> I would really like to hear some of your performance numbers.
> 
> -Eliezer

I will see what numbers I can share.

In general latency of both TCP/UDP, recvmsg only, single stream,
improved in ~50% and no bad impact on BW.

We're trying to find a solution to the epoll issue, and will share our
findings with netdev as soon as we have ones.

Amir
