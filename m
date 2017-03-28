From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] netfilter: ipset: Use max macro instead of ternary
 operator
Date: Tue, 28 Mar 2017 16:03:09 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1703281555450.21255@n3.vanv.qr>
References: <20170328133256.GA24590@singhal-Inspiron-5558>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: pablo@netfilter.org, outreachy-kernel@googlegroups.com,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: simran singhal <singhalsimran0@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328133256.GA24590@singhal-Inspiron-5558>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 2017-03-28 15:32, simran singhal wrote:

>This patch replaces ternary operator with macro max as it shorter and
>thus increases code readability.
>
>-	return (ret < 0 ? 0 : ret);
>+	return max(0, ret);

While the two are functionally equivalent, "max" conveys a meaning of 
"upper bound" (think ceil(3)), i.e. a _count of something_, but the 
function still returns a logical "error or bool".

Such a change may be usable in an IOCCC or a codegolf contest,
but it destroys rather than improves readability IMHO.
