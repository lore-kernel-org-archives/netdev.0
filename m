From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: Linux XIA - merge proposal
Date: Thu, 05 Mar 2015 08:31:09 -0800
Message-ID: <mda0cd$2rt$2@ger.gmane.org>
References: <54F5EF6E.9090303@digirati.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michel Machado wrote:

> Hi there,
> 
>     We have been developing Linux XIA, a new network stack that
> emphasizes evolvability and interoperability, for a couple of years, and
> it has now reached a degree of maturity that allows others to experiment
> with it.

>From looking at your wiki, "network stack" may have been a poor choice of 
term - it looks like rather than being a new network stack (which in Linux, 
is commonly used to refer to the software stack that lives between the APIs 
and the hardware), this is a new protocol (and framework _for_ protocols) 
operating at the same level of the network as IP, with ideas extending 
upwards through TCP.

Now, that's a rather different proposal - witness that RDS, TIPC, etc all 
made it into the kernel relatively easily, especially when compared to 
netmap, or any other system that tried to replace the Linux networking 
infrastructure.
