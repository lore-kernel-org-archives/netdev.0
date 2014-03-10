From: Eric Paris <eparis@redhat.com>
Subject: Re: [GIT PULL] namespaces fixes for 3.14-rcX
Date: Mon, 10 Mar 2014 09:59:04 -0400
Message-ID: <1394459944.17193.12.camel@localhost>
References: <874n3ir0uw.fsf_-_@xmission.com>
	 <87mwhaplo4.fsf_-_@xmission.com>
	 <20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
	 <20140304.165122.445822929490466603.davem@davemloft.net>
	 <87mwh5d1tf.fsf@xmission.com>
	 <20140304145037.d46ee775d293dd1ad60aa8e3@linux-foundation.org>
	 <87bnxesqf0.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, rgb@redhat.com,
	linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bnxesqf0.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-03-09 at 20:06 -0700, Eric W. Biederman wrote:
> Linus,
> 
> Please pull the for-linus branch from the git tree:
> 
>    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus
> 
>    HEAD: d211f177b28ec070c25b3d0b960aa55f352f731f audit: Update kdoc for audit_send_reply and audit_list_rules_send
> 
> Starting with 3.14-rc1 the audit code is faulty (think oopses and races)
> with respect to how it computes the network namespace of which socket to
> reply to, and I happened to notice by chance when reading through the
> code.
> 
> My efforts to get these fixes noticed by people who care about audit
> seem to have landed on deaf ears, so since these are namespace related I
> have put them in my tree.

This commentary sounds like a pile of crap seeing as how there was a
whole discussion around how to handle this stuff, which you were a part
of.  And that the audit tree already picked up these 2 patches.

In any case, since I haven't sent them to Linus and I'm glad that is
done, so feel free to consider this me Acking the pull request.
