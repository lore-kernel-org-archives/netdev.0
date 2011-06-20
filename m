From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] proc: Usable inode numbers for the namespace file descriptors.
Date: Mon, 20 Jun 2011 12:50:57 -0700
Message-ID: <m1ei2o5ljy.fsf@fess.ebiederm.org>
References: <20110521093936.GA3015@p183> <m11uzsxdty.fsf@fess.ebiederm.org>
	<20110521223054.GA3198@p183> <m1vcx3r3o5.fsf@fess.ebiederm.org>
	<20110523014303.GA2351982@jupiter.n2.diac24.net>
	<20110523014751.GB2351982@jupiter.n2.diac24.net>
	<m1wrgkavbm.fsf_-_@fess.ebiederm.org>
	<m1mxhgav9c.fsf_-_@fess.ebiederm.org>
	<20110620160656.GB16444@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	David Lamparter <equinox@diac24.net>,
	linux-kernel@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110620160656.GB16444@mail.hallyn.com> (Serge E. Hallyn's
	message of "Mon, 20 Jun 2011 11:06:56 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serge@hallyn.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> 
>> Assign a unique proc inode to each namespace, yielding an
>> identifier that userspace can use for identifying a namespace.
>> 
>> This has been a long requested feature and only blocked because
>> a naive implementation would put the id in a global space and
>> would ultimately require having a namespace for the names of
>> namespaces, making migration and certain virtualization tricks
>> impossible.
>> 
>> We still don't have per superblock inode numbers for proc, which
>> appears necessary for application unaware checkpoint/restart and
>> migrations (if the application is using namespace filedescriptors)
>> but that is now allowd by the design if it becomes important.
>> 
>> I have preallocated the ipc and uts initial proc inode numbers so
>> their structures can be statically initialized.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
> I've not looked at the setns patches enough, but from what I can see
> here it looks good.
>
> Acked-by: Serge Hallyn <serge@hallyn.com>

Thanks.

There are bugs in my existing proc bits that I am working on fixing so
this second patch will have a small update, before it gets merged.

But posting the patches I was looking for a little review and I was
announcing I had solved the technical problem of how we talk about
namespaces, without needing to introduce another namespace for
namespaces.

Eric
