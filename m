From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH 0/2] arm64: bpf: add BPF_ST and BPF_XADD instructions support
Date: Tue, 10 Nov 2015 14:41:39 -0800
Message-ID: <1447195301-16757-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yang.shi@linaro.org, linaro-kernel@lists.linaro.org, zlim.lnx@gmail.com,
 linux-kernel@vger.kernel.org, xi.wang@gmail.com, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: ast@kernel.org, daniel@iogearbox.net, catalin.marinas@arm.com,
 will.deacon@arm.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


Current ARM64 BPF JIT doesn't have store immediate and XADD instructions
support, and aarch64 doesn't have native instructions for them. Implement
them in instruction sequence. For detail, please refer to the commit log.

The implementation is tested by test_bpf kernel module.

The patches are applied after my BPF JIT stack fix [1].

[1] https://patches.linaro.org/56268/

Yang Shi (2):
      arm64: bpf: add 'store immediate' instruction
      arm64: bpf: add BPF XADD instruction

 arch/arm64/net/bpf_jit_comp.c | 39 ++++++++++++++++++++++++++++++++++-----
 1 file changed, 34 insertions(+), 5 deletions(-)
