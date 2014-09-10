From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/5] ceph: Convert pr_warning to pr_warn
Date: Wed, 10 Sep 2014 07:20:07 -0700
Message-ID: <1410358807.24028.44.camel@joe-AO725>
References: <cover.1410322181.git.joe@perches.com>
	 <714b7551f5a6ea5e721fed705568a39eeae4623b.1410322181.git.joe@perches.com>
	 <CALFYKtCiGXhMZ-f0B=TGSNGZCng8NVYWCV-wwOHq3xPdKO+-Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Ilya Dryomov <ilya.dryomov@inktank.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALFYKtCiGXhMZ-f0B=TGSNGZCng8NVYWCV-wwOHq3xPdKO+-Kw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-09-10 at 16:38 +0400, Ilya Dryomov wrote:
> On Wed, Sep 10, 2014 at 8:17 AM, Joe Perches <joe@perches.com> wrote:
> > Use the more common pr_warn.
> >
> > Other miscellanea:
> >
> > o Coalesce formats
> > o Realign arguments
[]
> > diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
[]
> > @@ -2828,8 +2828,9 @@ static void con_work(struct work_struct *work)
> >   */
> >  static void con_fault(struct ceph_connection *con)
> >  {
> > -       pr_warning("%s%lld %s %s\n", ENTITY_NAME(con->peer_name),
> > -              ceph_pr_addr(&con->peer_addr.in_addr), con->error_msg);
> > +       pr_warn("%s%lld %s %s\n",
> > +               ENTITY_NAME(con->peer_name),
> > +               ceph_pr_addr(&con->peer_addr.in_addr), con->error_msg);
> 
> Just wondering, why did you move ENITITY_NAME argument to the next
> line?  I see you are doing this pretty consistently.  Is this a style
> guideline or something?

Hello Ilya.

It's just a personal preference to have the
formats on one line and its arguments on
another when the format and its arguments
don't fit 80 columns.

Maximal 80 column fill isn't always easy for me
to read.

I find it easier to match formats and arguments
when scanning because my eye doesn't have to
scan to the end of the format line.

If you don't like it, it's your code.  Change it.

cheers, Joe
