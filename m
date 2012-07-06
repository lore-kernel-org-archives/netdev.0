From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH] force dentry revalidation after namespace change
Date: Fri, 6 Jul 2012 13:00:13 +0400
Message-ID: <4FF6A91D.60505@parallels.com>
References: <1341496805-26394-1-git-send-email-glommer@parallels.com> <8762a1vl76.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8762a1vl76.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/06/2012 03:31 AM, Eric W. Biederman wrote:
> The important difference there it is the directory that the dirent is
> in that the type comes from.  Not the dirent itself.
> 
>> >  	/* The sysfs dirent has been deleted */
>> >  	if (sd->s_flags & SYSFS_FLAG_REMOVED)
>> >  		goto out_bad;
> Glauber.  Do you think you can fix your patch and resubmit.
> 
> Eric

Yes. In a quick test it seems to work. I'll resubmit shortly.
