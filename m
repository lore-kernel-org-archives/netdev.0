From: Steve Modica <modica@sgi.com>
Subject: Re: sendfile() & unlink()
Date: Thu, 01 May 2003 12:33:29 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EB15A69.1000706@sgi.com>
References: <20030501172805.GB4580@udine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@Sun.COM>
In-Reply-To: <20030501172805.GB4580@udine>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Unlinking an open tmp file (so it doesn't show up in a directory listing 
) is a pretty common thing to do on Irix.  I sure hope one can do that 
on linux :)



Eric Lemoine wrote:
> Hi
> 
> What happens when unlink()ing a file that has just been sendfile()d? Is
> there any guarantee that the file remains in the buffer cache while TCP
> completes the xmit?
> 
> Thx.
> 


-- 
Steve Modica
work: 651-683-3224
mobile: 651-261-3201
Manager - Networking Drivers Group
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me
