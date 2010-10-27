From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] pktgen: Remove a dangerous debug print.
Date: Wed, 27 Oct 2010 13:38:50 -0700
Message-ID: <4CC88DDA.2030106@candelatech.com>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert.olsson@its.uu.se>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eugene Teo <eugene@redhat.com>
To: Nelson Elhage <nelhage@ksplice.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/2010 12:13 PM, Nelson Elhage wrote:
> We were allocating an arbitrarily-large buffer on the stack, which would allow a
> buggy or malicious userspace program to overflow the kernel stack.
>
> Since the debug printk() was just printing exactly the text passed from
> userspace, it's probably just as easy for anyone who might use it to augment (or
> just strace(1)) the program writing to the pktgen file, so let's just not bother
> trying to print the whole buffer.

Maybe just allocate that buffer on the heap instead of stack?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
