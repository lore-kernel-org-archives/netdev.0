From: Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 9/9] net: batman-adv: use per_cpu_add
 helper
Date: Sat, 03 Nov 2012 12:58:45 +0800
Message-ID: <5094A485.4060409@gmail.com>
References: <5093EE7E.6040400@gmail.com> <5905519.yWN2Ke3YlE@bentobox>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Kernel-Maillist <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org,
 Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, lindner_marek-LWAfsSFWpa4@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <5905519.yWN2Ke3YlE@bentobox>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

Sven Eckelmann said, at 2012/11/3 1:55:
> On Saturday 03 November 2012 00:02:06 Shan Wei wrote:
>> From: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>
>>
>> As Christoph Lameter said:
>>> In addition, following usage of per_cpu_ptr can be replaced by
>>> this_cpu_read.
>>>
>>> cpu=get_cpu()
>>> ....
>>> *per_cpu_ptr(p,cpu)
>>> ....
>>> ....
>>> put_cpu()
>>
>> Right.
>>
>> Signed-off-by: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>
>> ---
> 
> Is this really supposed to be the commit message?

Maybe it's ok when Linus said this. :-)

Christoph is the maintainer of per-cpu.
So........

PER-CPU MEMORY ALLOCATOR
M:      Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
M:      Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
T:      git git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git
S:      Maintained
F:      include/linux/percpu*.h
F:      mm/percpu*.c
F:      arch/*/include/asm/percpu.h

> 
> Kind regards,
> 	Sven
> 
