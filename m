From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC] TCP burst control
Date: Tue, 06 Jul 2004 19:20:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40EB5E0B.1030407@us.ibm.com>
References: <200407070009.i6709wiA026673@ms-smtp-03-eri0.southeast.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@redhat.com>,
        "'Stephen Hemminger'" <shemminger@osdl.org>, netdev@oss.sgi.com,
        rhee@ncsu.edu, lxu2@ncsu.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: Injong Rhee <rhee@eos.ncsu.edu>
In-Reply-To: <200407070009.i6709wiA026673@ms-smtp-03-eri0.southeast.rr.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Injong Rhee wrote:
> Hi David and Stephen,
> 
> We tested this rate halving. In fact, rate having in fact degrades the
> performance quite a bit. We can send you more information about it. Our test
> indicates that this feature introduces many timeouts (because of bursts),
> and also cause unnecessary cwnd backoff to reduce the transmission
> unjustifiably low -- so there are many (I will repeat, many) window and
> transmission oscillations during packet losses. We fix this problem

Could you point me to a paper or summary of your info?

> completely using our own special burst control. It is very simple and easy
> technique to implement. If you need some data to back up our claims, I will
> send you more. Once we implemented our burst control, we don't have any
> timeouts and not much fluctuation other than congestion control related.
> Currently with rate having, current Linux tcp stack is full of hacks that in
> fact, hurt the performance of linux tcp (sorry to say this). Our burst
> control, in fact, simplifies a lot of that and makes sure cwnd to follow
> very closely to whatever congestion control algorithm is intended it to
> behave. The Linux Reno burst control in fact interferes with the original
> congestion control (in fact, it tries to do its own), and its performance is
> very hard to predict.

Can you characterize the workload/traffic/error rate that each
would be best suited for?

thanks,
Nivedita
