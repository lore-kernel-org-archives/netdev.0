From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: fix a return in sockmap_get_from_fd()
Date: Fri, 18 Aug 2017 10:21:16 +0200
Message-ID: <5996A37C.2050502@iogearbox.net>
References: <20170818071210.wyq37kura6wz6bx6@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170818071210.wyq37kura6wz6bx6@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2017 09:27 AM, Dan Carpenter wrote:
> "map" is a valid pointer.  We wanted to return "err" instead.  Also
> let's return a zero literal at the end.
>
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
