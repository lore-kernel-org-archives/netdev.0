From: Sam Leffler <sam@errno.com>
Subject: Re: [PATCH] pktgen: sprintf arg type warning
Date: Sat, 09 Oct 2004 10:49:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416824C3.9040903@errno.com>
References: <20041008203027.643a2a97.rddunlap@osdl.org> <20041008221934.42a6bc7a.davem@davemloft.net> <41682021.3080400@errno.com> <20041009173644.GC30713@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "Randy.Dunlap" <rddunlap@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20041009173644.GC30713@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>>Other systems have addressed this problem by extending printf with 
>>portable %formats.
> 
> 
> Problem is that gcc -Wformat doesn't know the new format codes,
> and in Linux we still have to support old gcc versions.

Yes, gcc has been modified to understand the new %formats.  That's the 
advantage to distributing a full system and not just a kernel :)

> 
> Standard trick is to cast to long.
> 
> -Andi
> 
> 
