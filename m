From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
Date: Fri, 3 Aug 2012 15:29:10 -0700
Message-ID: <CA+55aFyOst4c3WHbPVbYkSBdBmLJUui5OvoVOh5AuPMnigwnEA@mail.gmail.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
 <1344003788-1417-2-git-send-email-levinsasha928@gmail.com>
 <20120803171515.GH15477@google.com> <501C407D.9080900@gmail.com>
 <20120803213017.GK15477@google.com> <501C458E.7050000@gmail.com>
 <20120803214806.GM15477@google.com> <501C4E92.1070801@gmail.com> <20120803222339.GN15477@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sasha Levin <levinsasha928@gmail.com>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org,
	mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com,
	netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20120803222339.GN15477@google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 3, 2012 at 3:23 PM, Tejun Heo <tj@kernel.org> wrote:
>
> I actually meant an enclosing struct.  When you're defining a struct
> member, simply putting the storage after a struct with var array
> should be good enough.  If that doesn't work, quite a few things in
> the kernel will break.

The unsigned member of a struct has to be the last one, so your struct
won't work.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
