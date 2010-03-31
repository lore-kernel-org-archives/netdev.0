From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/6] sysfs: Basic support for multiple super blocks
Date: Wed, 31 Mar 2010 08:47:57 -0500
Message-ID: <20100331134757.GA6132@us.ibm.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
 <1269973889-25260-1-git-send-email-ebiederm@xmission.com>
 <4BB2E098.7030202@kernel.org>
 <m1634d82e0.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1634d82e0.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Tejun Heo <tj@kernel.org> writes:
> >> index 30f5a44..030a39d 100644
> >> --- a/fs/sysfs/sysfs.h
> >> +++ b/fs/sysfs/sysfs.h
> >> @@ -114,6 +114,9 @@ struct sysfs_addrm_cxt {
> >>  /*
> >>   * mount.c
> >>   */
> >> +struct sysfs_super_info {
> >> +};
> >> +#define sysfs_info(SB) ((struct sysfs_super_info *)(SB->s_fs_info))
> >
> > Another nit picking.  It would be better to wrap SB in the macro
> > definition.  Also, wouldn't an inline function be better?
> 
> Good spotting.  That doesn't bite today but it will certainly bite
> someday if it isn't fixed.
> 
> I wonder how that has slipped through the review all of this time.

(let me demonstrate how: )

WTH are you talking about?  Unless you mean doing (SB) inside
the definition?

I actually was going to suggest dropping the #define as it obscures
the code, but I figured it would get more complicated later.

-serge
