From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH][bpf-next] bpf: remove redundant variable old_flags
Date: Thu, 12 Oct 2017 00:19:58 +0200
Message-ID: <59DE990E.1030601@iogearbox.net>
References: <20171011105623.19998-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011105623.19998-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/11/2017 12:56 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> Variable old_flags is being assigned but is never read; it is redundant
> and can be removed.
>
> Cleans up clang warning: Value stored to 'old_flags' is never read
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
