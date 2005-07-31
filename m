From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth: Additional ethtool support
Date: Sun, 31 Jul 2005 00:51:04 -0400
Message-ID: <42EC58B8.7080307@pobox.com>
References: <42D101EC.6000608@colorfullife.com> <20050710172833.GA1951@electric-eye.fr.zoreil.com> <42D16656.6000207@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Netdev <netdev@oss.sgi.com>,
        renaud.lienhart@free.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <42D16656.6000207@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> Not for a nic without complete documentation: What if an arch uses 
> 64-bit reads to read two registers at the same time? Not all nics like 
> that, for example IIRC natsemi explicitely mandates 32-bit reads.
> x86-64 doesn't, it uses 32-bit reads, but I don't like the idea of using 
> memcpy to read registers.
> 
> I agree with your other remarks, updated patch attached.


Going through my pending folder, I was about to apply all the queued 
forcedeth patches.  However, in two cases, you violated Rule #6 of

	http://linux.yyz.us/patch-format.html

Please resend ALL forcedeth patches, with proper descriptions, so I 
don't have to hunt through previous patch versions, and previous emails, 
to match up the correct description to the correct patch.

	Jeff
