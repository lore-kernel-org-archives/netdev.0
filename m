From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: sysctl, argument parsing, possible bug
Date: Tue, 8 Aug 2017 12:04:40 -0700
Message-ID: <20170808120440.713f1a38@xeon-e3>
References: <CAKv20-XwH=Ltqt6Xw++q2LbcHKmJhn76ZukF-Tr6a4Yd6rbJAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Massimo Sala <massimo.sala.71@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKv20-XwH=Ltqt6Xw++q2LbcHKmJhn76ZukF-Tr6a4Yd6rbJAg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Aug 2017 20:26:36 +0200
Massimo Sala <massimo.sala.71@gmail.com> wrote:

> I make another test with kernel 4.9.32-15.41
> 
> sysctl procps version 3.2.8
> 
>     sysctl net.ipv4.conf.eth0.100.forwarding
>     error: "net.ipv4.conf.eth0.100.forwarding" is an unknown key
> 
> 
> so I install busybox :
> 
> BusyBox v1.19.3
> 
>     busybox sysctl net.ipv4.conf.eth0.100.forwarding
>     net.ipv4.conf.eth0.100.forwarding = 0
> 
> It is working, as I expect reading busybox source sysctl.c
> 
> 
> 
> Stephen, I test
>     sysctl net/ipv4/conf/eth0.100/forwarding
> I confirm it  works.
> 
> 
> What is the problem ?
> 
> As sysctl, also automation tools and scripts cannot be "netdev names
> aware", and so they fail using the usual dot notation.
> 
> 
> I don't pretend to change sysctl to read from the /proc/sys/
> directory, as busybox does.
> 
> I suggest to add a  remark to the man page of sysctl, reporting the
> difference between the two tools and an example of the alternate
> syntax :
>     sysctl net/ipv4/conf/eth0.100/forwarding
> 
> 
> Thank you for your attention.
> Best regards, Massimo

Busybox has always been a restricted subset of the upstream standard tools.
If you have problems with busybox take it up with those developers directly;
this is not the right mailing list for that.
