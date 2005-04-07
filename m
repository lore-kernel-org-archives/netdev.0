From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH] Too aggressive cwnd backoff
Date: Thu, 07 Apr 2005 20:18:09 +0100
Message-ID: <42558771.1050605@ev-en.org>
References: <20050407164146.GA6479@ev-en.org> <20050407113351.17f8c094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050407113351.17f8c094.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 7 Apr 2005 19:41:46 +0300
> Baruch Even <baruch@ev-en.org> wrote:
> 
> 
>>However, in tcp_cwnd_down we will not stop reducing the cwnd until we
>>get to limit which is set to tp->ssthresh/2.
>>
>>The provided patch will set limit to tp->ssthresh. This was the original
>>behaviour in some older version of Linux.
> 
> 
> As stated in another email, it is still unknown where this "changed"
> or if it even "changed" at all in the vanilla sources.
> 
> Could you track this down?  I still strongly believe this is some
> WEB100 change you actually had in your tree, or something like
> that.

This change seems to be specific to us (Hamilton), I didn't find it as 
far back as 2.4.12 [1], it wasn't in any 2.6.x kernel and not even in 
web100 version alpha 2.3.2 which corresponds to kernel 2.4.23.

It does appear in the original patches that Doug Leith sent, so the only 
explanation left is that it's something he did in his tree originally. 
And for some reason I believed it was reverting an old change in the 
Linux kernel.

Baruch

[1] ftp.ie.kernel.org is missing 2.4.11 and ketchup died in my hands.
