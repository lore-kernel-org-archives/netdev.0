From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] net: filter: fix upper BPF instruction limit
Date: Fri, 20 Jun 2014 09:48:59 -0700
Message-ID: <CAGXu5jLk_LDZ1-ou0iPNvAb2QHJdX-xhGRtyov-YZsmUOVo0GA@mail.gmail.com>
References: <20140618223457.GA31568@www.outflux.net>
	<CAMEtUuzbPExM5dT+xDqbHtV5LZ3+E2Q0eq4xdmKWzLOZbTmuUQ@mail.gmail.com>
	<CAGXu5jLYZ0jrFhd54aUhooLBWBUT28TQTLb41G107s=4U7ZxqA@mail.gmail.com>
	<CAMEtUuwPug7Bbgi2ccOx4jxd2Q80AnVoiHeeBW2av=_sQMiSfg@mail.gmail.com>
	<CAGXu5j+ZW9f8gW71_r5gRsEZoO_2fC3F4YXh_J1CwxRY6Vfx1Q@mail.gmail.com>
	<53A40948.5020201@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Chema Gonzalez <chema@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53A40948.5020201@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 20, 2014 at 3:13 AM, Daniel Borkmann <dborkman@redhat.com> =
wrote:
> Hi Kees,
>
>
> On 06/19/2014 01:28 AM, Kees Cook wrote:
>>
>> On Wed, Jun 18, 2014 at 4:19 PM, Alexei Starovoitov <ast@plumgrid.co=
m>
>> wrote:
>>>
>>> On Wed, Jun 18, 2014 at 3:55 PM, Kees Cook <keescook@chromium.org> =
wrote:
>>>>
>>>> On Wed, Jun 18, 2014 at 3:48 PM, Alexei Starovoitov <ast@plumgrid.=
com>
>>>> wrote:
>>>>>
>>>>> On Wed, Jun 18, 2014 at 3:34 PM, Kees Cook <keescook@chromium.org=
>
>>>>> wrote:
>
> ...
>
>>>>> I wonder how did you catch this? :)
>>>>> Just code inspection or seccomp actually generating such programs=
?
>>>>
>>>>
>>>> In the process of merging my seccomp thread-sync series back with
>>>> mainline, I got uncomfortable that I was moving filter size valida=
tion
>>>> around without actually testing it. When I added it, I was happy t=
hat
>>>> my series was correctly checking size limits, but then discovered =
my
>>>> newly added check actually failed on an earlier kernel (3.2). Trac=
king
>>>> it down found the corner case under 3.15.
>>>>
>>>> Here's the test I added to the seccomp regression tests, if you're
>>>> interested:
>>>>
>>>> https://github.com/kees/seccomp/commit/794d54a340cde70a3bdf7fe0ade=
1f95d160b2883
>>>
>>>
>>> Nice. I'm assuming https://github.com/redpig/seccomp is still the m=
ain
>>> tree
>>> for seccomp testsuite=E2=80=A6
>>
>>
>> Yes. Will hasn't pulled this most recent set of changes.
>
>
> We were actually thinking about extending lib/test_bpf module with se=
ccomp
> tests, which is possible to a limited extend, but seccomp is also a b=
it
> more than just running a BPF program and making sure results fit.
>
> Are there any plans to put and extend test cases from [1] via user sp=
ace
> side into the kernel self-test directory, i.e. into something like
> tools/testing/selftests/seccomp/ so that in future new tests can be a=
dded
> or run from there? Might be worth to consider.

Yeah, I have this on my TODO list, but we need to juggle relicensing
the test suite (it is currently BSD, not GPLv2). I'll keep chasing
this.

-Kees

>
> Thanks,
>
> Daniel
>
>  [1] https://github.com/redpig/seccomp



--=20
Kees Cook
Chrome OS Security
