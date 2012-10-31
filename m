From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Date: Tue, 30 Oct 2012 19:48:19 -0700
Message-ID: <CA+55aFyU30Z2JS9XJ4KTordbAw-2EBVD7xF4K3eAhKVRCJw8YA@mail.gmail.com>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
 <20121030214257.GB2681@htj.dyndns.org> <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
 <1351646186.4004.41.camel@gandalf.local.home> <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
 <20121031022418.GE2616@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steven Rostedt <rostedt@goodmis.org>, Sasha Levin <levinsasha928@gmail.com>,
	Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
	mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com,
	netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com,
	mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com,
	dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com,
	Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com,
	jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com,
	snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org,
	dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20121031022418.GE2616@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2012 at 7:24 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> BTW, how serious have you been back at KS when you were talking about
> pull requests killing a thousand of lines of code being acceptable
> at any point in the cycle?

Well... I'm absolutely a lot more open to pull requests that kill code
than not, but I have to admit to being a bit more worried about stuff
like your execve/fork patches that touch very low-level code.

So I think I'll punt that for 3.8 anyway.

         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
