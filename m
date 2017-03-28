From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] netfilter: ipset: Use max macro instead of ternary
 operator
Date: Tue, 28 Mar 2017 14:13:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFC0145@AcuExch.aculab.com>
References: <20170328133256.GA24590@singhal-Inspiron-5558>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "outreachy-kernel@googlegroups.com"
        <outreachy-kernel@googlegroups.com>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "coreteam@netfilter.org" <coreteam@netfilter.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'simran singhal' <singhalsimran0@gmail.com>,
        "pablo@netfilter.org" <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328133256.GA24590@singhal-Inspiron-5558>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: simran singhal
> Sent: 28 March 2017 14:33
> This patch replaces ternary operator with macro max as it shorter and
> thus increases code readability. Macro max return the maximum of the two
> compared values.
...
>  	/* Convert error codes to nomatch */
> -	return (ret < 0 ? 0 : ret);
> +	return max(0, ret);

It might be shorter but it isn't more readable.

	David
