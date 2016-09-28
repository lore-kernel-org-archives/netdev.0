From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 08:16:46 -0400 (EDT)
Message-ID: <20160928.081646.1634500099795129398.davem@davemloft.net>
References: <20160928112703.GW1876@uranus.lan>
        <20160928.080701.1194277590163223525.davem@davemloft.net>
        <60b2e075-e852-f0c2-c188-631f547791d5@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, eric.dumazet@gmail.com,
        dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: jhs@mojatatu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <60b2e075-e852-f0c2-c188-631f547791d5@mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Wed, 28 Sep 2016 08:09:28 -0400

> On 16-09-28 08:07 AM, David Miller wrote:
> 
>> Right, it would be legal for an existing user to have code that
>> explicitly initializes every member of the structure, including 'pad'.
>> So we have to keep that member around, at a minimum, for their sake.
>>
> 
> I think we need to start labelling any new pad fields added as
> "Not UAPI. Do not fsck fondle this".

They must initialize it to zero.
