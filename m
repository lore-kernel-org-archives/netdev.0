From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] kref: add function for reading kref value
Date: Mon, 12 Dec 2011 17:21:37 +0200
Message-ID: <CAEnQRZBiVDAHH+uZ=Ugk=UP5qSvvMViGTM-bRWr+E27zivOUug@mail.gmail.com>
References: <1323693892-11570-1-git-send-email-dbaluta@ixiacom.com>
	<20111212150255.GA7506@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	adobriyan@gmail.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111212150255.GA7506@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 12, 2011 at 5:02 PM, Greg KH <greg@kroah.com> wrote:
> On Mon, Dec 12, 2011 at 02:44:52PM +0200, Daniel Baluta wrote:
>> We can easily get kref refcount value by accesing
>> kref->refcount but it is better to have a function
>> for this.
>
> No, you should NEVER need the value of the kref, if you do, you are
> doing something wrong.
>
> What code needs this patch?

I plan to replace raw refcount patterns from net/ with kref, and
I have noticed that there are some parts of code who need access
to kref->refcount value.

e.g:

core/neighbour.c:152:			if (atomic_read(&n->refcnt) == 1 &&
core/neighbour.c:801:			if (atomic_read(&n->refcnt) == 1 &&
sched/cls_u32.c:459:	if (ht->refcnt == 1) {


thanks,
Daniel.
