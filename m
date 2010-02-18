From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v4 1/3] sysctl: refactor integer handling proc code
Date: Thu, 18 Feb 2010 05:58:20 +0200
Message-ID: <201002180258.20869.opurdila@ixiacom.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <4B7A5A23.3080309@redhat.com> <201002161248.56598.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002161248.56598.opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 16 February 2010 09:48:56 you wrote:
> On Tuesday 16 February 2010 10:41:07 you wrote:
> > > +
> > > +     if (!write && !first && left && !err)
> > > +             err = proc_put_newline(&buffer, &left);
> > > +     if (write && !err)
> > > +             err = proc_skip_wspace(&buffer, &left);
> > > +     if (err == -EFAULT /* do we really need to check for -EFAULT? */
> > > || +         (write && first))
> > > +             return err ? : -EINVAL;
> >
> > The logic here seems messy, adding one or two goto's may help?
> 
> OK, I'll give it a try.
> 

After a couple of tries which didn't make it clearer, I've given up. Maybe its 
not clear, but is not too terribly messy IMO. I'll rather spend time on 
getting the new list range format done.
