From: Zefan Li <lizefan@huawei.com>
Subject: Re: [PATCH 3.4 140/176] lib/checksum.c: fix carry in csum_tcpudp_nofold
Date: Fri, 10 Apr 2015 09:42:36 +0800
Message-ID: <55272A8C.7040707@huawei.com>
References: <1428569028-23762-1-git-send-email-lizf@kernel.org> <1428569224-23820-140-git-send-email-lizf@kernel.org> <20150409174407.GA8601@magnum.frso.rivierawaves.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <lizf@kernel.org>, <stable@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Mike Frysinger <vapier@gentoo.org>, <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Karl Beldan <karl.beldan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150409174407.GA8601@magnum.frso.rivierawaves.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/4/10 1:44, Karl Beldan wrote:
> On Thu, Apr 09, 2015 at 04:46:28PM +0800, lizf@kernel.org wrote:
>> From: karl beldan <karl.beldan@gmail.com>
>>
>> 3.4.107-rc1 review patch.  If anyone has any objections, please let me know.
>>
>> ------------------
>>
>>
>> commit 150ae0e94634714b23919f0c333fee28a5b199d5 upstream.
>>
> 
> Hi Zefan,
> 
> The above patch introduced a build error for some archs, please consider
> applying 9ce357795ef208faa0d59894d9d119a7434e37f3 
> "lib/checksum.c: fix build for generic csum_tcpudp_nofold" as well.
>  

Will fix. Thanks for the review!
