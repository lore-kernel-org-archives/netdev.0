From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Tue, 17 Jun 2003 13:46:01 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3EEF7E09.8080608@us.ibm.com>
References: <3ED80230.2030508@us.ibm.com>	<20030531.110249.12960077.yoshfuji@linux-ipv6.org> <20030530.233257.21920899.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030530.233257.21920899.davem@redhat.com>
List-Id: netdev.vger.kernel.org

Hi Dave and Yoshfuji,

I have a question about the following, which seems to be the
approach both of you prefer. I thought we need a new routing
message type called RTM_GETPLIST which will return full prefix
list. If you use RTA_RA6INFO, then should that trigger only
when the prefix list has changed (add or delete) ? Should I
have both interfaces, one for returning entire list (RTM) and
one for changes in prefix list (RTA) ?

Please let me know if my understanding is correct.

Thanks,

- KK

David S. Miller wrote:
>    From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
>    Date: Sat, 31 May 2003 11:02:49 +0900 (JST)
>    
>    Again, what I proposed was to store prefix information on fib with 
>    some flags to represent advertised by routers and give user-space 
>    the RA information using new rtattr (RTA_RA6INFO or something like that).
> 
> This sounds very reasonable.
> 

