From: jamal <hadi@cyberus.ca>
Subject: Re: Luca Deri's paper: Improving Passive Packet Capture: Beyond
	Device Polling
Date: 03 Apr 2004 18:02:12 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1081033332.2037.61.camel@jzny.localdomain>
References: <20040330142354.GA17671@outblaze.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Yusuf Goolamabbas <yusufg@outblaze.com>
In-Reply-To: <20040330142354.GA17671@outblaze.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-03-30 at 09:23, Yusuf Goolamabbas wrote:
> Maybe this might be of interest to netdev hackers
> 
> Luca Deri's paper
>   Improving Passive Packet Capture: Beyond Device Polling
> 
> http://www.net-security.org/dl/articles/Ring.pdf
> 

Thanks for posting this.
I am a little suprised at some of the results especially with
NAPI + packet mmap. 
I have had no problem at all handling wire rate 100mbps with 
tulip-NAPI in 2.4.x using packet mmap on a p3 or maybe it was a p2; This
is zero drops at 148.8Kpps.
Jason Lunz actually seemed to have been doing more work on this and
e1000 - he could provide better perfomance numbers.
It should also be noted that infact packet mmap already uses rings.

cheers,
jamal
