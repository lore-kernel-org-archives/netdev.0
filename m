From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
 buffer is large enough
Date: Tue, 4 Mar 2014 14:50:37 -0800
Message-ID: <20140304145037.d46ee775d293dd1ad60aa8e3@linux-foundation.org>
References: <874n3ir0uw.fsf_-_@xmission.com>
	<87mwhaplo4.fsf_-_@xmission.com>
	<20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
	<20140304.165122.445822929490466603.davem@davemloft.net>
	<87mwh5d1tf.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rgb@redhat.com,
	eparis@redhat.com, linux-audit@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87mwh5d1tf.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 04 Mar 2014 14:41:16 -0800 ebiederm@xmission.com (Eric W. Biederman) wrote:

> David Miller <davem@davemloft.net> writes:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Tue, 4 Mar 2014 13:30:04 -0800
> >
> >> On Fri, 28 Feb 2014 20:50:19 -0800 ebiederm@xmission.com (Eric W. Biederman) wrote:
> >> 
> >>> 
> >>> Modify audit_send_reply to directly use a non-blocking send and
> >>> to return an error on failure (if anyone cares).
> >>> 
> >>> Modify audit_list_rules_send to use audit_send_reply and give up
> >>> if we can not send a packet.
> >>> 
> >>> Merge audit_list_rules into iaudit_list_rules_send as the code
> >>> is now sufficiently simple to not justify to callers.
> >>> 
> >>> Kill audit_send_list, audit_send_reply_thread because using
> >>> a separate thread for replies is not needed when sending
> >>> packets syncrhonously.
> >> 
> >> Nothing much seems to be happening here?
> 
> Well you picked up the patch that fixes the worst of the bugs that I was
> complaining about.  Beyond that I don't know what makes sense.

Oh, so I did.  I wasn't planning on merging it myself, hoping that
someone who hasaclue will step in.  Help.
