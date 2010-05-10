From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: bug: micrel phy init (2.6.34-rc7)
Date: Mon, 10 May 2010 15:56:34 -0700
Message-ID: <4BE88F22.3060408@oracle.com>
References: <4BE88BED.4030400@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David J. Choi" <david.choi@micrel.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BE88BED.4030400@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/10/10 15:42, Randy Dunlap wrote:
> Loading the micrel phy driver BUGs (no device present):
> 
> [  623.821462] BUG: unable to handle kernel NULL pointer dereference at (null)
> [  623.822164] IP: [<ffffffff8123c9f0>] strcmp+0x6/0x44
> [  623.822164] PGD 7d4bd067 PUD 7d6bb067 PMD 0 
> [  623.822164] Oops: 0000 [#1] SMP
> 
> 
> Full kernel log and config are attached.
> 
> Not a regression -- this is a new driver.

OK, I see that this was reported & fixed on May-06.  :)


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
