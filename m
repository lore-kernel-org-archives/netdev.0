From: "David S. Miller" <davem@redhat.com>
Subject: Re: Patch: Make linkwatch more robust against rtnl holders
Date: Wed, 18 Feb 2004 17:11:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040218171159.62e76670.davem@redhat.com>
References: <200402151511.49432.srompf@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <200402151511.49432.srompf@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Feb 2004 15:11:47 +0100
Stefan Rompf <srompf@isg.de> wrote:

> the attached patch updates the linkwatch code so that it backs off and retries 
> whenever it cannot get the rtnl semaphore.

I think we should fix locking conflicts created by things like what
the sungem driver is doing instead.
