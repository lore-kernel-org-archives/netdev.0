From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: TCP stops sending ACKs after 32 mesg...
Date: Fri, 30 Aug 2002 14:24:48 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <49347.7301243276$1030706681@news.gmane.org>
References: <010901c25016$d59d17a0$2304a8c0@Ionizer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Saurabh Bansal <sbansal@aplion.stpn.soft.net>
Content-Disposition: inline
In-Reply-To: <010901c25016$d59d17a0$2304a8c0@Ionizer>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Fri, Aug 30, 2002 at 04:47:30PM +0530, Saurabh Bansal wrote:
> Hi,
> 
> It has been more than a week since I posted this query to the LINUX 
> group and haven't heard anything from the group-side in this context.
> Is my query under processing/observation OR something else??

  Slipped in between spam-floods, or something...

> Hope to get some positive response from your side this time!
> Thanks And Regards
> Saurabh
>
> ----- Original Message ----- 
> From: Saurabh Bansal 
> To: netdev@oss.sgi.com 
> Cc: linux-net@vger.kernel.org 
> Sent: Wednesday, August 21, 2002 1:26 PM
> 
> Hi all,
> 
>     I did this experiment with the a set of two processes behaving as
> a sender/receiver set on the same Linux machine. What the experiment was 
> that---
> 
> "The sender has to send some fixed-size (20 bytes) mesgs to the 
>  receiver but the receiver has not to pick-up anyone of them."
> 
>  What has been observed is, TCP buffers the first 32 messages into the 
> receive socket queue of receiver, AND THEN it stops sending ack's for 
> next mesg. As a result, the sender keeps on trying to send the 33rd 
> mesg, but gets no ack's and connection gets down within 15-20 minutes. 

  Are you sure you are emptying the receiver socket when some
  new data arrives ?

> Another important observations about this experiment are :
> 
> 1) These two processes were running on the same Linux system with 
>    kernel version 2.2.xx. This problem doesn't come with Linux-kernel 
>    2.4.xx.

  I recall having seen this kind of problems in 2.1/2.2 series,
  possibly a bug-fix was added in late 2.2 to restore earlier
  behaviour in 2.0...

  I had implemented a problem circumvention in one of my software
  suites by making the socket non-blocking, and adding proper
  select() calls.

> 2) If these processes are run on different Linux m/c's with kernel 
>    2.2.xx, the problem doesn't appear.

  Quite so.

> 3) The socket APIs used for sending/receiving mesg are send()/recv().
> 4) The problem has no relevance with the size of mesg. I have seen the 
>    same behavior with 1-byte mesg to 1k-byte mesg.
> 
> Can anyone tell me if there is any bug/limitation with the Linux-kernel 
> 2.2.xx in comparison to kernel 2.4.xx in the above problem-context??

  I faintly recall something which might be what you are describing.
 
> Saurabh Bansal

/Matti Aarnio
