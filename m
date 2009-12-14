From: David Miller <davem@davemloft.net>
Subject: Re: nfs broken in net-next? -- now in mainline -- bisected:
 d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
Date: Sun, 13 Dec 2009 19:33:01 -0800 (PST)
Message-ID: <20091213.193301.112613647.davem@davemloft.net>
References: <86802c440912121841j34cde8ecv892d7d74a32313ac@mail.gmail.com>
	<4B251CE4.9080401@gmail.com>
	<4B256A7E.5000508@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mingo@elte.hu, sri@us.ibm.com,
	herbert@gondor.apana.org.au, torvalds@linux-foundation.org,
	sjayaraman@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: yinghai@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753210AbZLNDdF@vger.kernel.org>
In-Reply-To: <4B256A7E.5000508@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>
Date: Sun, 13 Dec 2009 14:28:14 -0800

> Eric Dumazet wrote:
>> [PATCH] udp: udp_lib_get_port() fix
>> 
>> Now we can have a large udp hash table, udp_lib_get_port() loop
>> should be converted to a do {} while (cond) form,
>> or we dont enter it at all if hash table size is exactly 65536.
>> 
>> Reported-by: Yinghai Lu <yinghai@kernel.org>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
 ...
> thanks. that fix the problem.

Applied, thanks everyone.
