From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: Make linkwatch more robust against rtnl holders
Date: Fri, 20 Feb 2004 17:44:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402201744.21348.srompf@isg.de>
References: <200402151511.49432.srompf@isg.de> <20040218171159.62e76670.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040218171159.62e76670.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

> > the attached patch updates the linkwatch code so that it backs off and
> > retries whenever it cannot get the rtnl semaphore.
>
> I think we should fix locking conflicts created by things like what
> the sungem driver is doing instead.

On the other hand, I'm not aware of any convention when flush_scheduled_work() 
is allowed to be called. As long as anyone inside kernel space is can 
schedule work and anyone else can wait for completion, it does not hurt to 
make a schedule task less vulnerable to deadlocks.

Stefan
