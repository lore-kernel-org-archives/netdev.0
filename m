From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] test_bpf: extend tests for 32-bit endianness
 conversion
Date: Sat, 27 Jun 2015 11:14:40 +0200
Message-ID: <558E6980.5070101@iogearbox.net>
References: <1435332320-6476-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@plumgrid.com>
To: Xi Wang <xi.wang@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435332320-6476-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/26/2015 05:25 PM, Xi Wang wrote:
> Currently "ALU_END_FROM_BE 32" and "ALU_END_FROM_LE 32" do not test if
> the upper bits of the result are zeros (the arm64 JIT had such bugs).
> Extend the two tests to catch this.
>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Xi Wang <xi.wang@gmail.com>

Thanks for extending the test suite!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
