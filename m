From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: sysctl, argument parsing, possible bug
Date: Tue, 1 Aug 2017 19:40:00 -0700
Message-ID: <20170801194000.68ac99e1@xeon-e3>
References: <CAKv20-VuR4J0PJOOfsRmEPMhB+vKYMdPsp5wDgVkoYwrHxgLGw@mail.gmail.com>
        <CAM_iQpXtHACnD8kmmHd4bcg+Khy5Y0K=HMmc08avTSHov4zN1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Massimo Sala <massimo.sala.71@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXtHACnD8kmmHd4bcg+Khy5Y0K=HMmc08avTSHov4zN1A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Aug 2017 14:27:37 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Tue, Aug 1, 2017 at 1:47 PM, Massimo Sala <massimo.sala.71@gmail.com> wrote:
> > cat /proc/sys/net/ipv4/conf/eth0.100/forwarding
> > 0
> >
> > sysctl net.ipv4.conf.eth0.100.forwarding
> > error: "net.ipv4.conf.eth0.100.forwarding" is an unknown key
> >  
> 
> Use echo instead, sysctl doesn't understand eth0.100
> is a netdev name, sigh.

sysctl happily accepts / as a separator see man sysctl(8)

PARAMETERS
       variable
              The  name  of  a  key to read from.  An example is kernel.ostype.  The '/' separator is also
              accepted in place of a '.'.
