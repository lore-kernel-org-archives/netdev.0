From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 03/14] bpf: introduce syscall(BPF, ...) and
 BPF maps
Date: Tue, 1 Jul 2014 22:33:46 -0700
Message-ID: <CAMEtUuzHrzyUG1nie5cWzGZYTDTnqL7vPvAmPZdie_uSM_wqRA@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-4-git-send-email-ast@plumgrid.com>
	<CALCETrV3WLBmHewCZgfhCkjODWfq_byRg6sF7HpqZ6n9BVMBVQ@mail.gmail.com>
	<CAMEtUuzWs+MbSOGGD-Rc01DHKASa4GxbHdtCrSCLit4cUM35mA@mail.gmail.com>
	<CALCETrWy6=dzTycy-ckiMR92+nQeqAWp_Hw=hi__VSzVWZ43Ag@mail.gmail.com>
	<CAMEtUuwRf--qyPu3rKB7-57KAu2NdsQdEpVRckqabmf61g+h-g@mail.gmail.com>
	<CALCETrUoOTtQ1R1A8Ak35fxHxaFTPHWP6oZWnXDVLKa_ESziWw@mail.gmail.com>
	<CAMEtUuzS=9Y_ZjigofvQ5d3=89RS=+d8-WGPk9VVSMc3qawWsw@mail.gmail.com>
	<CALCETrWq+=Q3G2Smjd2RYES42UagpmD0EKxFM+jNufi6_qitWg@mail.gmail.com>
	<CAMEtUuyKY=haqP11VgXHdfHBkqfB-KxuswygUd7hDPLkOFz9HQ@mail.gmail.com>
	<CALCETrW3=idHOKF56d94suiA0NoiUGwr7pENm13q6=1XMbBPdw@mail.gmail.com>
	<CAMEtUuyX-tybpMEW=f-00qgq9h3AcHovLNW0_bak3oT4Oj3FuA@mail.gmail.com>
	<CALCETrWpA5M74pKJLFJ0t-2hi2TXMi_BV6DbJMmdDOJyOoHOyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrWpA5M74pKJLFJ0t-2hi2TXMi_BV6DbJMmdDOJyOoHOyg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 1, 2014 at 8:11 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> w=
rote:
> On Mon, Jun 30, 2014 at 10:47 PM, Alexei Starovoitov <ast-uqk4Ao+rVK7QFizaE/u3fw@public.gmane.org=
m> wrote:
>> On Mon, Jun 30, 2014 at 3:09 PM, Andy Lutomirski <luto-kltTT9wpgjKXcx/E+B78Qg@public.gmane.org=
t> wrote:
>>> On Sat, Jun 28, 2014 at 11:36 PM, Alexei Starovoitov <ast@plumgrid.=
com> wrote:
>>>> On Sat, Jun 28, 2014 at 6:52 PM, Andy Lutomirski <luto@amacapital.=
net> wrote:
>>>>> On Sat, Jun 28, 2014 at 1:49 PM, Alexei Starovoitov <ast@plumgrid=
=2Ecom> wrote:
>>>>>>
>>>>>> Sorry I don't like 'fd' direction at all.
>>>>>> 1. it will make the whole thing very socket specific and 'net' d=
ependent.
>>>>>> but the goal here is to be able to use eBPF for tracing in embed=
ded
>>>>>> setups. So it's gotta be net independent.
>>>>>> 2. sockets are already overloaded with all sorts of stuff. Addin=
g more
>>>>>> types of sockets will complicate it a lot.
>>>>>> 3. and most important. read/write operations on sockets are not
>>>>>> done every nanosecond, whereas lookup operations on bpf maps
>>>>>> are done every dozen instructions, so we cannot have any overhea=
d
>>>>>> when accessing maps.
>>>>>> In other words the verifier is done as static analyzer. I moved =
all
>>>>>> the complexity to verify time, so at run-time the programs are a=
s
>>>>>> fast as possible. I'm strongly against run-time checks in critic=
al path,
>>>>>> since they kill performance and make the whole approach a lot le=
ss usable.
>>>>>
>>>>> I may have described my suggestion poorly.  I'm suggesting that a=
ll of
>>>>> these global ids be replaced *for userspace's benefit* with fds. =
 That
>>>>> is, a map would have an associated struct inode, and, when you lo=
ad an
>>>>> eBPF program, you'd pass fds into the kernel instead of global id=
s.
>>>>> The kernel would still compile the eBPF program to use the global=
 ids,
>>>>> though.
>>>>
>>>> Hmm. If I understood you correctly, you're suggesting to do it sim=
ilar
>>>> to ipc/mqueue, shmem, sockets do. By registering and mounting
>>>> a file system and providing all superblock and inode hooks=E2=80=A6=
 and
>>>> probably have its own namespace type=E2=80=A6 hmm=E2=80=A6 may be.=
 That's
>>>> quite a bit of work to put lightly. As I said in the other email t=
he first
>>>> step is root only and all these complexity just not worth doing
>>>> at this stage.
>>>
>>> The downside of not doing it right away is that it's harder to
>>> retrofit in without breaking early users.
>>>
>>> You might be able to get away with using anon_inodes.  That will
>>
>> Spent quite a bit of time playing with anon_inode_getfd(). The model
>> works ok for seccomp, but doesn't seem to work for tracing,
>> since tracepoints are global. Say, syscall(bpf, load_prog) returns
>> a process-local fd. This 'fd' as a string can be written to
>> debugfs/tracing/events/.../filter which will increment a refcnt of a=
 global
>> ebpf_program structure and will keep using it. When process exits it=
 will
>> close all fds which in case of ebpf_prog_fd should be a nop, since
>> the program is still attached to a global event. Now we have a
>> program and maps that still alive and dangling, since tracepoint eve=
nts
>> keep coming, but no new process can access it. Here we just lost all
>> benefits of making it 'fd' based. Theoretically we can extend tracin=
g to
>> be fd-based too and tracepoints will auto-detach upon process exit,
>> but that's not going to work for all other global events. Like netwo=
rking
>> components (bridge, ovs, =E2=80=A6) are global and they won't be add=
ing
>> fd-based interfaces.
>> I'm still thinking about it, but it looks like that any process-loca=
l
>> ebpf_prog_id scheme is not going to work for global events. Thoughts=
?
>
> Hmm.  Maybe these things do need global ids for tracing, or at least
> there need to be some way to stash them somewhere and find them again=
=2E
> I suppose that debugfs could have symlinks to them, but I don't know
> how hard that would be to implement or how awkward it would be to use=
=2E
>
> I imagine there's some awkwardness regardless.  For tracing, if I
> create map 75 and eBPF program 492 that uses map 75, then I still nee=
d
> to remember that map 75 is the map I want (or I need to parse the eBP=
=46
> program later on).
>
> How do you imagine the userspace code working?  Maybe it would make
> sense to add some nlattrs for eBPF programs to map between referenced
> objects and nicknames for them.  Then user code could look at
> /sys/kernel/debug/whatever/nickname_of_map to resolve the map id or
> even just open it directly.

I want to avoid string names, since they will force new 'strtab', 'symt=
ab'
sections in the programs/maps and will uglify the user interface quite =
a bit.

Back in september one loadable unit was: one eBPF program + set of maps=
,
but tracing requirements forced a change, since multiple programs need
to access the same map and maps may need to be pre-populated before
the programs start executing, so I've split maps and programs into most=
ly
independent entities, but programs still need to think of maps as local=
:
=46or example I want to do a skb leak check 'tracing filter':
- attach this program to kretprobe of __alloc_skb():
  u64 key =3D (u64) skb;
  u64 value =3D bpf_get_time();
  bpf_update_map_elem(1/*const_map_id*/, &key, &value);
- attach this program to consume_skb and kfree_skb tracepoints:
  u64 key =3D (u64) skb;
  bpf_delete_map_elem(1/*const_map_id*/, &key);
- and have user space do:
  prior to loading:
  bpf_create_map(1/*map_id*/, 8/*key_size*/, 8/*value*/, 1M /*max_entri=
es*/)
  and then periodically iterate the map to see whether any skb stayed
  in the map for too long.

Programs need to be written with hard coded map_ids otherwise usability
suffers, so I did global 32-bit id in this RFC, but this indeed doesn't=
 work
for unprivileged chrome browser unless programs are previously loaded
by root and chrome only does attach to seccomp.

So here is the non-root bpf syscall interface I'm thinking about:

ufd =3D bpf_create_map(map_id, key_size, value_size, max_entries);

it will create a global map in the system which will be accessible
in this process via 'ufd'. Internally this 'ufd' will be assigned globa=
l map_id
and process-local map_id that was passed as a 1st argument.
To do update/lookup the process will use bpf_map_xxx_elem(ufd,=E2=80=A6=
)

Then to load eBPF program the process will do:
ufd =3D bpf_prog_load(prog_type, ebpf_insn_array, license)
and instructions will be referring to maps via local map_id that
was hard coded as part of the program.

Beyond the normal create_map, update/lookup/delete, load_prog
operations (that are accessible to both root and non-root), the root us=
er
gains one more operations: bpf_get_global_id(ufd) that returns
global map_id or prog_id. This id can be attached to global events
like tracing. Non-root users lose ability to do delete_map and
unload_prog (they do close(ufd) instead), so this ops are for root
only and operate on global ids.
This is the cleanest way I could think of to combine non-root
security, per-process id and global id all in one API. Thoughts?
