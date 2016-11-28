From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: selftests: include <sys/resource.h> to
 fix build error
Date: Mon, 28 Nov 2016 13:22:17 +0100
Message-ID: <583C2179.7040101@iogearbox.net>
References: <20161128114541.10829-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128114541.10829-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/28/2016 12:45 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> Fix incomplete type build error on struct rlimit by including
> <sys/resource.h>, fixes:
>
> test_lru_map.c:552:9: error: variable ‘r’ has initializer
>   but incomplete type
>    struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
>           ^
> test_lru_map.c:552:21: error: ‘RLIM_INFINITY’ undeclared
>   (first use in this function)
>    struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Thanks for the patch, fixed here already:

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=e00c7b216f34444252f3771f7d4ed48d4f032636
