From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 00:14:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414E04D6.5010106@eurodev.net>
References: <E1C8way-0000aH-00@gondolin.me.apana.org.au> <414DF05E.7020601@eurodev.net> <20040919212033.GA9254@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040919212033.GA9254@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

Herbert Xu wrote:

>However, let's do it properly rather than adding random wake_up calls.
>  
>

When the buffer is full, I wake up the user process and put the kernel 
thread to sleep to let the user process empty the queue.

>You're waking up a process based on its pid. With thread groups this is simply broken.
>  
>

I didn't know about netlink applications using thread groups, in that 
case, submit a patch to delete that wake up call.

regards,
Pablo
