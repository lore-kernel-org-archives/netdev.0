From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/3] bpf: Remove dead variable
Date: Mon, 16 Oct 2017 20:54:36 +0200
Message-ID: <59E5006C.4090303@iogearbox.net>
References: <20171016181856.12497-1-richard@nod.at> <20171016181856.12497-2-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ast@kernel.org
To: Richard Weinberger <richard@nod.at>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016181856.12497-2-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/2017 08:18 PM, Richard Weinberger wrote:
> task is never used in bpf_get_current_uid_gid(), kill it.
>
> Signed-off-by: Richard Weinberger <richard@nod.at>
> ---
>   kernel/bpf/helpers.c | 1 -
>   1 file changed, 1 deletion(-)
>
> diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
> index e8845adcd15e..511c9d522cfc 100644
> --- a/kernel/bpf/helpers.c
> +++ b/kernel/bpf/helpers.c
> @@ -131,7 +131,6 @@ const struct bpf_func_proto bpf_get_current_pid_tgid_proto = {
>
>   BPF_CALL_0(bpf_get_current_uid_gid)
>   {
> -	struct task_struct *task = current;
>   	kuid_t uid;
>   	kgid_t gid;
>
>

Needs to be squashed into patch 1/3?
