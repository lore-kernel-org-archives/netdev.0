From: "David S. Miller" <davem@redhat.com>
Subject: Re: Deadlock in sungem/ip_auto_config/linkwatch
Date: Mon, 5 Jan 2004 11:02:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040105110248.04ed06b7.davem@redhat.com>
References: <1073307882.2041.98320.camel@brick.watson.ibm.com>
	<200401051550.51063.srompf@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mostrows@watson.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <200401051550.51063.srompf@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 5 Jan 2004 15:50:50 +0100
Stefan Rompf <srompf@isg.de> wrote:

> Btw, what is the planned difference between rtnl_shlock() and rtnl_exlock()? 
> Even though the later is a null operation right now, I don't want to hold 
> more locks than needed in the linkwatch code.

The idea was originally to make the RTNL semaphore a read-write one,
but I doubt we'll ever make that happen and the shlock bits will just
disappear entirely.
