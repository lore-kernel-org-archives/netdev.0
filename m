From: Ben Greear <greearb@candelatech.com>
Subject: Re: return values for hard_start_xmit and dev_queue_xmit
Date: Wed, 13 Oct 2004 11:53:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416D79B1.1090707@candelatech.com>
References: <416D7526.8050206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <416D7526.8050206@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:

> The dev_queue_xmit method is fairly well documented in dev.c, but
> there are zero comments in the netdevice.h file to explain what the
> acceptable return values for hard_start_xmit are.

Actually, looks like I'm wrong here.  The comments in dev.c say that
error codes are < 0, but in fact, this can easily return NET_XMIT_DROP
which is a positive value (1).

Maybe the truth is that any non-zero return value from dev_queue_xmit
is an error?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
