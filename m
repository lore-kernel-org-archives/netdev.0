From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] netpoll: shorten carrier detect timeout
Date: Fri, 11 Mar 2005 05:35:05 +0100
Message-ID: <42311FF9.5010007@trash.net>
References: <2.454130102@selenic.com> <422A4A38.4040303@trash.net> <20050306002015.GD3120@waste.org> <422A564D.4080809@trash.net> <20050310230117.GP3120@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Jeff Moyer <jmoyer@redhat.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050310230117.GP3120@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> Ok, on closer inspection, the current logic is: the NIC reports
> carrier detect nearly instaneously and thus its carrier detect
> reporting is considered unreliable. Rather than immediately sending
> packets, we wait for some interval for it to really be up so that the
> backlog of console messages doesn't get pumped into the bit bucket.
> 
> So I'm going to change it from "flaky" to "untrustworthy" and add a
> comment.

Why don't you trust an instaneously available carrier? Any
reason to assume there will be false positives?

Regards
Patrick
