From: P@draigBrady.com
Subject: Re: Xeon smp performance
Date: Mon, 08 Mar 2004 15:15:30 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404C8E12.4060403@draigBrady.com>
References: <20040308132354.77437.qmail@web21101.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: satya srikanth <satyasrikanth2001@yahoo.com>
In-Reply-To: <20040308132354.77437.qmail@web21101.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

satya srikanth wrote:
> Hi,
>    I am writing a simple sniffer program that will
> sniff packets in a gigabit network. I am using a dual
> processor 2 GHz Xeon processor with one Intel Pro-1000
> desktop adapter, running 2.4.20-8smp linux.=20
>    I found that for all packet sizes and network
> bandwidth, 2.4.20-8 uniprocessor version that uses
> only one processor is performing better than
> 2.4.20-8smp using two processors in terms of packet
> drops and CPU utilization. Each processor in smp is
> utilizing more CPU than one processor in uni-processor
> case. What is the reason for this peculiar behaviour?
> Is it possible for me to use the power of second
> processor without adding more NICs. Will I face
> similar problems with 2.6 also? Anybody familiar with
> these please help me out.

That matches my experience. My chipset was Intel E7501
with 2 intel pro-1000 adapters. I used the base 2.4.20 kernel
with latest intel drivers.

I had 2 processes capturing packets and noticed that
2 CPUs is 7% slower than one CPU. Note I was using a non SMP
kernel for the one CPU case.

I'm going to have to look into improving this soon.
First I'm going to look at IRQ and process affinity.

P=E1draig.
