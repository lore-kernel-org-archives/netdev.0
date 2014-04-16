From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Wed, 16 Apr 2014 12:21:49 -0400
Message-ID: <20140416162149.GI1257@htj.dyndns.org>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
 <20140416002010.GA5035@redhat.com>
 <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140416.085743.1614257692560892039.davem@davemloft.net>
 <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
 <1397664837.19767.410.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@amacapital.net>,
	David Miller <davem@davemloft.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Daniel Walsh <dwalsh@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Simo Sorce <ssorce@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1397664837.19767.410.camel@willson.li.ssimo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Wed, Apr 16, 2014 at 12:13:57PM -0400, Simo Sorce wrote:
> The only one that *may* be reasonable is the "secret" cgroup name one,
> however nobody seem to come up with a reason why it is legitimate to
> allow to keep cgroup names secret.

Ugh, please don't play security games with cgroup names.  It is one of
the identifying properties of a task, like a pid, and will be used in
other parts of the kernel to match groups of tasks.  If we play
security peekaboo with cgroup names, it has to be transitive and puts
burdens on all its future uses.  Unless there are *REALLY* strong
rationales, which can also justify hiding pids, this isn't happening.

Thanks.

-- 
tejun
