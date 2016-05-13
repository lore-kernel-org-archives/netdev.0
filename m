From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf V2] netfilter: fix oops in nfqueue during netns error
 unwinding
Date: Fri, 13 May 2016 23:20:29 +0200
Message-ID: <20160513212029.GC29941@breakpoint.cc>
References: <1462981273-21676-1-git-send-email-fw@strlen.de>
 <20160512094725.GB1777@salvia>
 <87twi3qmlf.fsf@x220.int.ebiederm.org>
 <20160512164000.GA9815@breakpoint.cc>
 <87a8jtrbk3.fsf@x220.int.ebiederm.org>
 <20160513200442.GA29941@breakpoint.cc>
 <87zirtofgp.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, dale.4d@gmail.com,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87zirtofgp.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman <ebiederm@xmission.com> wrote:
> Florian could you test and verify this patch fixes your issues?

Yes, this seems to work.

Pablo, I'm fine with this patch going into -nf/stable but I do not think
making the pointers per netns is a desireable option in the long term.

> Unlike the other possibilities that have been discussed this also
> addresses the nf_queue path as well as the nf_queue_hook_drop path.

The nf_queue path should have been fine, no?

Or putting it differently: can we start processing skbs before a netns
is fully initialized?
