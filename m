From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v1] samples/bpf: Add a .gitignore for binaries
Date: Sun, 12 Feb 2017 18:43:58 -0700
Message-ID: <8277c7cc-8f44-40ec-1f7e-53c404d84292@cumulusnetworks.com>
References: <20170212212356.11675-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170212212356.11675-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/12/17 2:23 PM, Mickaël Salaün wrote:
> diff --git a/samples/bpf/.gitignore b/samples/bpf/.gitignore
> new file mode 100644
> index 000000000000..a7562a5ef4c2
> --- /dev/null
> +++ b/samples/bpf/.gitignore
> @@ -0,0 +1,32 @@
> +fds_example
> +lathist

...

Listing each target is going to be a PITA to maintain. It would be
better to put targets into a build directory (bin?) and ignore the
directory.
