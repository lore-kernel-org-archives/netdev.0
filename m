From: "Xiaoliang (David) Wei" <weixl@caltech.edu>
Subject: Re: gigabit ethernet
Date: Thu, 12 Feb 2004 01:34:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <402B48A8.3060800@caltech.edu>
References: <20040212083915.73516.qmail@web21109.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: satya srikanth <satyasrikanth2001@yahoo.com>
In-Reply-To: <20040212083915.73516.qmail@web21109.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Satya,

      Did you check the CPU utilization? If you use smaller packet size, 
the interrupt rate may be a problem.
      You can modulate the NIC's interrupt rate. See the document for 
details:
http://www.intel.com/support/network/adapter/1000/e1000.htm#parameters


      Also, I assume the round trip propagation delay for your 
connections is very small (such as <10ms)?


-David

satya srikanth wrote:
> Sir,
>     I need some help from you. I am using 2 xeon(2
> GHz) machines each with two processors running linux
> 2.4.20-8smp kernel and having intel PRO/1000 gigabit
> adapter NIC card(e1000 driver). I tried connecting
> both of them using a gigabit switch. I am getting
> gigabit speed only if I use my own TCP sockets sending
> packets of size around 1400 bytes. If I send packets
> of size around 500 bytes, I am getting maximum of only
> 500 Mbps. I noticed that NIC is receiving all the
> packets but they are getting dropped in the kernel.
>         I tried changing the settings like
> netdev_max_backlog to 30000 and rmem_max, wmem_max and
> txqueuelen, but of no use. Can you please suggest some
> changes that I need to make to achieve this speed.
> (Like changing number of Rx interrupts, Tx interrupts
> etc). Can you please suggest some other links where I
> can get some useful information. Will linux router
> project LRP help me to achieve it.
> 
>         with regards,
>         Satya Srikanth.
> 


-- 
------------------------------------------------------
Xiaoliang (David) Wei   Graduate Student of CS@Caltech
WWW: http://www.cs.caltech.edu/~weixl
======================================================
