From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: [PATCH 0/6] MIPS/BPF fixes for 4.3
Date: Fri, 5 Jun 2015 09:26:51 +0100
Message-ID: <55715D4B.9020703@imgtec.com>
References: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com> <557081A6.5010407@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	"Daniel Borkmann" <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>, <linux-mips@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <557081A6.5010407@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/04/2015 05:49 PM, Alexei Starovoitov wrote:
> On 6/4/15 3:56 AM, Markos Chandras wrote:
>> Here are some fixes for MIPS/BPF. The first 5 patches do some cleanup
>> and lay the groundwork for the final one which introduces assembly
>> helpers
>> for MIPS and MIPS64. The goal is to speed up certain operations that do
>> not need to go through the common C functions. This also makes the
>> test_bpf
>> testsuite happy with all 60 tests passing. This is based in 4.1-rc6.
> 
> looks like these patches actually fix two real bugs, right?
> If so, I think you probably want them in 'net' tree ?

I was thinking to have them in the MIPS tree to be honest. The original
MIPS/BPF went via the MIPS tree as well. It also makes it easier for me
to work with Ralf on minor fixes, merge conflicts etc.

> 
> Different arch maintainers take different stance towards bpf jit
> changes. x86, arm and s390 are ok with them going through Dave's trees,
> since often there are dependencies on bpf core parts.
> So please state clearly what tree you want these patches to go in.
> 
> btw, in the net-next tree bpf testsuite has 246 tests and the last
> ten are very stressful for JITs.

Interesting. Thanks. I will rebase my tree shortly after 4.2-rc1 then
and run the testsuite again. I will post a v2 if I spot more problems
with it.

-- 
markos
