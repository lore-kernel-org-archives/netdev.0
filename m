From: jchapman@katalix.com
Subject: Re: How to improve small packet performance
Date: Wed, 13 Aug 2003 23:23:43 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060835023.3f3b0ecfc97b4@webmail.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: minniewkitty@yahoo.com.cn
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I downloaded the eepro100 NAPI patch and tried it in my test setup (a
1GHz P-III configured as a 2-port bridge, 2.4.20-8 RH9 kernel).  I see
e100-napi perform much better than eepro100, which is what I was 
expecting.

  e100-v3.0.0dev12-napi     93k packets/sec
  eepro100-napi-020619	    49k packets/sec

When doing a bidirectional test, the eepro100 driver locks up
completely, although it seems to survive with 128 byte packets (where
the event rate is less).
  
What's your test setup? How are you generating your test traffic? Do
your NIC cards share the same irq?

-jc

minnie wu wrote:

> Hi, all!
>      I tried e100-napi, but it's performance is still worse than 
>      eepro100-napi. It seems that napi cannot meet my needs. Any ideas?
>  
> jchapman@katalix.com wrote:
>  
> > Try the latest e100 development driver from sf.net/projects/e1000. 
> > Make >sure you compile it with NAPI enabled.
> 
> minnie wu wrote:
> 
> > Hi, all!
> >      I'm working on e100/eepro100, kernel version 2.4.20. I 
> >      used NAPI, but the 64 byte small packet dual throughout
> >      is only 28M/s. How to improve small packet performance further?
> 




-------------------------------------------------
This mail sent through IMP: http://horde.org/imp/
