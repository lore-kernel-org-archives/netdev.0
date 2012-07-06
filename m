From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH v2] fail dentry revalidation after namespace change
Date: Fri, 6 Jul 2012 13:44:27 +0400
Message-ID: <4FF6B37B.4040005@parallels.com>
References: <1341565747-15374-1-git-send-email-glommer@parallels.com> <87hatli62r.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Thelen <gthelen@google.com>,
	Serge Hallyn <serge.hallyn@canonical.com>,
	Tejun Heo <tj@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87hatli62r.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/06/2012 01:37 PM, Eric W. Biederman wrote:
> Glauber Costa <glommer@parallels.com> writes:
> 
>> When we change the namespace tag of a sysfs entry, the associated dentry
>> is still kept around. readdir() will work correctly and not display the
>> old entries, but open() will still succeed, so will reads and writes.
> 
> Note reads and writes of file handles open before the move should
> continue to work.

Well, yes. But do you see it as a big problem?

This can probably be fixed as well, but I foresee a big hackishness in
the way =p
