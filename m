From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch -next] bpf: null dereference allocating large arrays
Date: Sat, 22 Nov 2014 10:45:51 -0800
Message-ID: <CAADnVQL+zgLbsAcLv-qSFmUi9yOy0qB9m-hO75E53fXu6yL6hA@mail.gmail.com>
References: <20141122183059.GC6994@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20141122183059.GC6994@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 22, 2014 at 10:30 AM, Dan Carpenter
<dan.carpenter@oracle.com> wrote:
> There is a typo here, "array" is null so we can't dereference it and
> also the size calculation should match the kzalloc() on the lines
> before.

Not sure what tree you're looking at...
it was more than typo, but it was fixed 4 days ago.
See commit daaf427c6ab39 ("bpf: fix arraymap NULL deref and missing
overflow and zero size checks")
