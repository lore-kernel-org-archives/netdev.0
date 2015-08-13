From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Revert "net: limit tcp/udp rmem/wmem to
 SOCK_{RCV,SND}BUF_MIN"
Date: Thu, 13 Aug 2015 15:56:36 -0700
Message-ID: <1439506596.7960.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438806414-751067-1-git-send-email-calvinowens@fb.com>
	 <20150809.224114.818332231954008575.davem@davemloft.net>
	 <20150811033406.GA1136819@mail.thefacebook.com>
	 <20150810.204630.1903301700926701432.davem@davemloft.net>
	 <20150812045420.GA3908557@mail.thefacebook.com>
	 <20150813212134.GA3070917@mail.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, sorin@returnze.ro
To: Calvin Owens <calvinowens@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150813212134.GA3070917@mail.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-08-13 at 14:21 -0700, Calvin Owens wrote:
> Commit 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to
> SOCK_{RCV,SND}BUF_MIN") modified four sysctls to enforce that the values
> written to them are not less than SOCK_MIN_{RCV,SND}BUF.
> 
...
> 
> This reverts commit 8133534c760d4083f79d2cde42c636ccc0b2792e.
> 
> Fixes: 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to SOCK_MIN...")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Sorin Dumitru <sorin@returnze.ro>
> Signed-off-by: Calvin Owens <calvinowens@fb.com>

Acked-by: Eric Dumazet <edumazet@google.com>
