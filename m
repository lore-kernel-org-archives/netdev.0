From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call of
 del_timer_sync()
Date: Mon, 25 May 2015 12:17:37 +0300
Message-ID: <20150525091737.GQ4150@mwanda>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
 <CAJ=9CzbPmo+f4zjY4CqQ7TsUENpwy+zHcpxeLTbAH0DAZSkqsQ@mail.gmail.com>
 <556268BC.5050807@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Sudip Mukherjee <sudip@vectorindia.org>,
 gregkh@linuxfoundation.org, linux-wireless@vger.kernel.org,
 Stable <stable@vger.kernel.org>, netdev@vger.kernel.org,
 Haggai Eran <haggai.eran@gmail.com>, Arek Rusniak <arek.rusi@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <556268BC.5050807@lwfinger.net>
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

On Sun, May 24, 2015 at 07:11:40PM -0500, Larry Finger wrote:
> On 05/24/2015 02:03 PM, Haggai Eran wrote:
> >On 24 May 2015 at 00:16, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> >>The driver is reporting a warning at kernel/time/timer.c:1096 due to calling
> >>del_timer_sync() while in interrupt mode. Such warnings are fixed by calling
> >>del_timer() instead.
> >>
> >>Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> >>Cc: Stable <stable@vger.kernel.org>
> >>Cc: Haggi Eran <haggai.eran@gmail.com>
> >
> >Hi,
> >
> >I haven't been using kernel v4.1 so I haven't seen this warning, but looking
> >at the code it seems to originate from the two recent patches to remove
> >_cancel_timer and _cancel_timer_ex. I see that there's another patch in lkml [1]
> >that changes del_timer_sync back to del_timer in more places. Perhaps it
> >could prevent other warnings like this in the future.
> >
> >Regards,
> >Haggai
> >
> >[1] https://lkml.org/lkml/2015/5/15/226
> 
> Yes, the script kiddies make changes they do not understand and
> screw everything up. Unfortunately, I did not catch these in review.
> I think I will submit V2 and blast the contributor.

Don't blast the contributor...  These are special intern patches that
dont' go through the normal review process.  The intern process is over
this year.  The lack of normal review introduced a number of bugs this
year.  I always complain to Greg about it and he says that I should join
the intern mailing list if I care so much.

regards,
dan carpenter
