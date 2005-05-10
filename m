From: Rick Jones <rick.jones2@hp.com>
Subject: Re: IPsec performance over UDP
Date: Tue, 10 May 2005 11:41:27 -0700
Message-ID: <42810057.4020800@hp.com>
References: <200505101949.12236.m.iatrou@freemail.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Iatrou <m.iatrou@freemail.gr>
In-Reply-To: <200505101949.12236.m.iatrou@freemail.gr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Iatrou wrote:
> Hi,
> 
> I did some testing for IPsec performance over UDP. I used two identical PCs, 
> connected back-to-back, with Intel Xeon 2.8GHz (SMP/SMT disabled), 512MB RAM, 
> e1000 (82546EB), running Linux 2.6.11.7.  
> 
> I tested AES {128,192,256}, DES, 3DES, SHA, MD5 and various combinations of 
> them for ESP and AH.
> 
> Network performance:
> http://members.hellug.gr/iatrou/udp-throughput.png
> 
> CPU utilization:
> http://members.hellug.gr/iatrou/udp-cpu.png
> 
> The "unexpected" result is that there is 30% idle time even if the network is 
> not saturated! 

Perhaps the sending side got intra-stack flow-controlled?

rick jones
