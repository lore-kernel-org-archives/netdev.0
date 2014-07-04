From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH RFC] arm64: eBPF JIT compiler
Date: Fri, 4 Jul 2014 09:07:51 +0100
Message-ID: <20140704080751.GA23379@arm.com>
References: <1404278424-31176-1-git-send-email-zlim.lnx@gmail.com>
 <20140703091450.GB12958@arm.com>
 <CABg9mcuCQHXacgq-C7A=G5GH_p7b0TxCYB8A9qXvGJSoSbjs5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Catalin Marinas <Catalin.Marinas@arm.com>,
 Chema Gonzalez <chema@google.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Daniel Borkmann <dborkman@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "David S. Miller" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Alexei Starovoitov <ast@plumgrid.com>
To: Z Lim <zlim.lnx@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <CABg9mcuCQHXacgq-C7A=G5GH_p7b0TxCYB8A9qXvGJSoSbjs5A@mail.gmail.com>
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

On Fri, Jul 04, 2014 at 07:56:54AM +0100, Z Lim wrote:
> On Thu, Jul 3, 2014 at 2:14 AM, Will Deacon <will.deacon@arm.com> wrote:
> > Does this sound remotely feasible?
> 
> So I looked at insn.c and the only overlap at this point is B/BL codegen.
> A whole lot more, e.g. arithmetic, logical, and memory ops, will need
> to be shuffled in.

Yup, the more the merrier. I just want to avoid having N subtley different
encoders/decoders, as this stuff tends to be hard to review and easy to make
small mistakes.

> Let me address Alexei's review comments and send out a v2.
> After that, I can take a stab at consolidating bpf_jit.h into
> insn.{c,h}. Sounds good to you?

Perfect.

Will
