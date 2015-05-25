From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call
 of del_timer_sync()
Date: Mon, 25 May 2015 10:52:43 -0500
Message-ID: <5563454B.1080400@lwfinger.net>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>	<CAJ=9CzbPmo+f4zjY4CqQ7TsUENpwy+zHcpxeLTbAH0DAZSkqsQ@mail.gmail.com>	<556268BC.5050807@lwfinger.net>	<20150525091737.GQ4150@mwanda>
 <CAK-LDb+1WscLTFw=NDY=_aUOGw72a4wRsqCU-1N+KJ11k15S5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Sudip Mukherjee <sudip@vectorindia.org>,
 Greg KH <gregkh@linuxfoundation.org>, Haggai Eran <haggai.eran@gmail.com>,
 linux-wireless@vger.kernel.org, Stable <stable@vger.kernel.org>,
 netdev@vger.kernel.org, Arek Rusniak <arek.rusi@gmail.com>
To: Vaishali Thakkar <vthakkar1994@gmail.com>,
 Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CAK-LDb+1WscLTFw=NDY=_aUOGw72a4wRsqCU-1N+KJ11k15S5w@mail.gmail.com>
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

On 05/25/2015 04:37 AM, Vaishali Thakkar wrote:
>
> On 25 May 2015 14:49, "Dan Carpenter" <dan.carpenter@oracle.com
> <mailto:dan.carpenter@oracle.com>> wrote:
>  >
>  > On Sun, May 24, 2015 at 07:11:40PM -0500, Larry Finger wrote:
>  > > On 05/24/2015 02:03 PM, Haggai Eran wrote:
>  > > >On 24 May 2015 at 00:16, Larry Finger <Larry.Finger@lwfinger.net
> <mailto:Larry.Finger@lwfinger.net>> wrote:
>  > > >>The driver is reporting a warning at kernel/time/timer.c:1096 due to calling
>  > > >>del_timer_sync() while in interrupt mode. Such warnings are fixed by calling
>  > > >>del_timer() instead.
>  > > >>
>  > > >>Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net
> <mailto:Larry.Finger@lwfinger.net>>
>  > > >>Cc: Stable <stable@vger.kernel.org <mailto:stable@vger.kernel.org>>
>  > > >>Cc: Haggi Eran <haggai.eran@gmail.com <mailto:haggai.eran@gmail.com>>
>  > > >
>  > > >Hi,
>  > > >
>  > > >I haven't been using kernel v4.1 so I haven't seen this warning, but looking
>  > > >at the code it seems to originate from the two recent patches to remove
>  > > >_cancel_timer and _cancel_timer_ex. I see that there's another patch in
> lkml [1]
>  > > >that changes del_timer_sync back to del_timer in more places. Perhaps it
>  > > >could prevent other warnings like this in the future.
>  > > >
>  > > >Regards,
>  > > >Haggai
>  > > >
>  > > >[1] https://lkml.org/lkml/2015/5/15/226
>  > >
>  > > Yes, the script kiddies make changes they do not understand and
>  > > screw everything up. Unfortunately, I did not catch these in review.
>  > > I think I will submit V2 and blast the contributor.
>  >
>  > Don't blast the contributor...  These are special intern patches that
>  > dont' go through the normal review process.  The intern process is over
>  > this year.  The lack of normal review introduced a number of bugs this
>  > year.  I always complain to Greg about it and he says that I should join
>  > the intern mailing list if I care so much.
>
> I am sorry for those patches. It was me who introduced those bugs. Yes, it was
> sent during Outreachy process. But it was my mistake as a newbie. May be I
> should have taken care of interrupt mode thing.
>
> I would like to fix it if someone is not doing it. Sorry again. I will take care
> of these things in my future patches.

No, one of us will fix the problems with r8712u. The hardware is needed for 
proper testing, and I doubt that you have it.

Larry
