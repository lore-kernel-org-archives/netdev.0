From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] pktgen: reduce stack usage
Date: Fri, 18 Feb 2005 14:20:40 -0800
Message-ID: <42166A38.4020200@osdl.org>
References: <20050218134219.3f079110.rddunlap@osdl.org> <20050218221121.GA22845@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev <netdev@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050218221121.GA22845@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Randy.Dunlap <rddunlap@osdl.org> :
> 
>>(resend)
>>Any comments this time?
> 
> 
> Did I miss a simultaneous use of both buffers or could it be possible to
> save an extra IP_NAME_SZ bytes of data with an evil ugly union ?

That's probably doable, I'll double-check it and modify the patch...

> Btw, does anyone intend to fix the use of sleepable functions in 
> proc_thread_write() with spinlock ("thread_lock") held or should
> I allocate it some cycles ?

-- 
~Randy
