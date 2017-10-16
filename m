From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 2/3] bpf: Remove dead variable
Date: Mon, 16 Oct 2017 20:59:33 +0200
Message-ID: <2297422.9nBBslcvMo@blindfold>
References: <20171016181856.12497-1-richard@nod.at> <20171016181856.12497-2-richard@nod.at> <59E5006C.4090303@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ast@kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59E5006C.4090303@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 16. Oktober 2017, 20:54:36 CEST schrieb Daniel Borkmann:
> On 10/16/2017 08:18 PM, Richard Weinberger wrote:
> > task is never used in bpf_get_current_uid_gid(), kill it.
> > 
> > Signed-off-by: Richard Weinberger <richard@nod.at>
> > ---
> > 
> >   kernel/bpf/helpers.c | 1 -
> >   1 file changed, 1 deletion(-)
> > 
> > diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
> > index e8845adcd15e..511c9d522cfc 100644
> > --- a/kernel/bpf/helpers.c
> > +++ b/kernel/bpf/helpers.c
> > @@ -131,7 +131,6 @@ const struct bpf_func_proto
> > bpf_get_current_pid_tgid_proto = {> 
> >   BPF_CALL_0(bpf_get_current_uid_gid)
> >   {
> > 
> > -	struct task_struct *task = current;
> > 
> >   	kuid_t uid;
> >   	kgid_t gid;
> 
> Needs to be squashed into patch 1/3?

I can squash it into 1/3, I kept it that way because
even without 1/3 this variable is unused.

Thanks,
//richard
