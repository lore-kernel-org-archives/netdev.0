From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: fix garbled TX error message
Date: Tue, 14 Jan 2014 15:49:32 +0400
Message-ID: <52D5244C.6070603@cogentembedded.com>
References: <201401110241.49471.sergei.shtylyov@cogentembedded.com> <20140113.232935.776174177146650322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20140113.232935.776174177146650322.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 14-01-2014 11:29, David Miller wrote:

>> sh_eth_error() in case of a TX error tries to print a message using 2 dev_err()
>> calls with the first string not finished by '\n', so that the resulting message
>> would inevitably come out garbled, with something like "3net eth0: " inserted
>> in the middle.  Avoid that by merging 2 calls into one.

>> While at it, insert an empty line after the nearby declaration.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> Applied, thanks.

> I don't think this is really -stable material, sorry.

    Right, this is not even a fix anymore, at least not from 2.6.31 times (if 
Joe's estimate was correct), and I was going to resubmit it as a cleanup. 
Should have warned you not to apply yet but didn't, sorry.

WBR, Sergei

