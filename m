From: Harsh <hanemade@gmail.com>
Subject: Re: loopback packet processing.
Date: Wed, 15 Dec 2004 14:38:54 +0530
Message-ID: <cfc95936041215010821f2c22a@mail.gmail.com>
References: <cfc9593604121402424f2a9ba5@mail.gmail.com>
	 <Pine.BSF.4.58.0412141649050.71544@ece.iisc.ernet.in>
Reply-To: Harsh <hanemade@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: MANJUNATH <manjunath@ece.iisc.ernet.in>
In-Reply-To: <Pine.BSF.4.58.0412141649050.71544@ece.iisc.ernet.in>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi MANJUNATH,
         I actually did a lot work on kernel packet processing and 
found that ping packet creation enters in ethernet.c.
           Also can you tell me what happens in ip_finish_output2 when
ping ICMP packet is created by kernel? what header is added there.
            Also in receving end control enters in ethernet.c to check
eth->h_proto field which is ETH_P_IP. How & where it is added by
kernel in case of PING packet?

regards,
Harsh.

On Tue, 14 Dec 2004 16:53:33 +0530 (IST), MANJUNATH
<manjunath@ece.iisc.ernet.in> wrote:
> 
> 
> Hi,
> 
>   When u send data to the loopback address, control never
>   Enters "ethernet" modules.(Data link layer)
> 
>   Since ping inturn uses program interface to ICMP which is a part
>   of IPV4 s/w, for loopback ping IP modules themselves replies. Ethernet
>   does not come into picture.
> 
> cheers,
> Manjunath
> 
>
