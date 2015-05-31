From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call of
 del_timer_sync()
Date: Sun, 31 May 2015 11:53:47 +0900
Message-ID: <20150531025347.GA8074@kroah.com>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
 <55634793.4050002@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, Stable <stable@vger.kernel.org>,
 Haggi Eran <haggai.eran@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <55634793.4050002@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, May 25, 2015 at 11:02:27AM -0500, Larry Finger wrote:
> On 05/23/2015 04:16 PM, Larry Finger wrote:
> >The driver is reporting a warning at kernel/time/timer.c:1096 due to calling
> >del_timer_sync() while in interrupt mode. Such warnings are fixed by calling
> >del_timer() instead.
> >
> >Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> >Cc: Stable <stable@vger.kernel.org>
> >Cc: Haggi Eran <haggai.eran@gmail.com>
> >---
> 
> Greg,
> 
> Please drop this patch. The same fixes were submitted as
> https://lkml.org/lkml/2015/5/15/226.

That's not working for me at the moment, what was the subject: name?  I
think I already applied it to the testing tree...

thanks,

greg k-h
