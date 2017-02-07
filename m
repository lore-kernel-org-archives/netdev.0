From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v3 04/11] bpf: Use bpf_load_program() from the
 library
Date: Tue, 7 Feb 2017 15:17:43 -0800
Message-ID: <589A5597.7090107@fb.com>
References: <20170207214500.27496-1-mic@digikod.net>
 <20170207214500.27496-5-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Shuah Khan <shuah@kernel.org>
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170207214500.27496-5-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/7/17 1:44 PM, Mickaël Salaün wrote:
> -	union bpf_attr attr;
> +	union bpf_attr attr = {};
>
> -	bzero(&attr, sizeof(attr));

I think somebody mentioned that there are compilers out there
that don't do it correctly, hence it was done with explicit bzero.
Arnaldo, Wang, do you remember the details?
