From: Nicolas Schichan <nschichan@freebox.fr>
Subject: Re: [PATCH v2 net-next 3/3] ARM: net: bpf_jit_32: support BPF_S_ANC_SECCOMP_LD_W
 instruction
Date: Mon, 29 Apr 2013 14:39:29 +0200
Message-ID: <517E6A01.4040407@freebox.fr>
References: <1367029047-14830-1-git-send-email-xi.wang@gmail.com> <1367029047-14830-4-git-send-email-xi.wang@gmail.com> <517B6FC5.7070003@redhat.com> <CAKU6vyathpp4Ky_kcTu_WFenLEdo9Mai4TUE=EWYo9=UuQUMcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Will Drewry <wad@chromium.org>,
	Eric Dumazet <edumazet@google.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Laight <david.laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKU6vyathpp4Ky_kcTu_WFenLEdo9Mai4TUE=EWYo9=UuQUMcg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/27/2013 08:32 PM, Xi Wang wrote:
> On Sat, Apr 27, 2013 at 2:27 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> Arent't you doing here a similar thing in terms of getting arch as Eric
>> criticized (Nicolas' implementation does not use that part btw.)? Also,
>> even if it would be possible here, now your 2 JIT implementations differ
>> in behaviour. I think this is unintended.
>
> Eric's comment was about x86, where the audit arch could change on the
> fly.  For ARM, the audit arch doesn't change---syscall_get_arch()
> always returns AUDIT_ARCH_ARM.

Hi,

Indeed, syscall_get_arch() will only return AUDIT_ARCH_ARM on ARM right now. 
This might be more future proof to call syscall_get_arch() though. The main 
reason that comes to my mind would be an AArch64 kernel with support for 
AArch32 userland tasks. This would I expect require a different AUDIT_ARCH 
constant to differenciate between AArch64 and AArch32 tasks.

Regards,

-- 
Nicolas Schichan
Freebox SAS
