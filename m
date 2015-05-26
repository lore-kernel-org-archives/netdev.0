From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call of
 del_timer_sync()
Date: Tue, 26 May 2015 18:48:26 +0300
Message-ID: <20150526154826.GJ11588@mwanda>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
 <CAJ=9CzbPmo+f4zjY4CqQ7TsUENpwy+zHcpxeLTbAH0DAZSkqsQ@mail.gmail.com>
 <556268BC.5050807@lwfinger.net> <20150525091737.GQ4150@mwanda>
 <1432575448.2846.63.camel@perches.com>
 <20150526044611.GA3465@sudip-PC>
 <1432616108.2846.83.camel@perches.com>
 <20150526050212.GC3465@sudip-PC>
 <1432616879.2846.86.camel@perches.com>
 <20150526141401.GC21573@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Sudip Mukherjee <sudip@vectorindia.org>,
 netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 Stable <stable@vger.kernel.org>, Haggai Eran <haggai.eran@gmail.com>,
 Joe Perches <joe@perches.com>, Arek Rusniak <arek.rusi@gmail.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20150526141401.GC21573@kroah.com>
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

On Tue, May 26, 2015 at 07:14:01AM -0700, Greg KH wrote:
> I take the blame for any problems with Outreachy patches.  Given the
> huge volume of them, one bug out of 900 isn't that bad of a percentage.

We don't get many bugs through outreachy, but this isn't the first one.
For example, in March and April people complained about:

95745e9b1de2 ('staging: lustre: Use kasprintf.')
45de432775d6 ('Staging: rtl8712: Use memdup_user() instead of copy_from_user()')

There have been others but I have a short memory.  We have this
discussion every time.  How come no one caught this bug in review??  Oh,
it never went through the list.

I'm fine with 5 bugs per 900 patches or whatever.  I wish that the
patches came to the list, but I get that that would double your review
workload to review 900 patches on the outreachy list and again on the
normal dev list.

regards,
dan carpenter
