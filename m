From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: lsm naming dilemma. Re: [RFC v3 07/22] landlock: Handle file comparisons
Date: Mon, 19 Sep 2016 18:10:52 -0700
Message-ID: <CAMp4zn8_GhvL5gGLrkADVSTP9Z4VO78bXtX8wbzFSa1P7j-yfA@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-8-mic@digikod.net>
 <20160914210649.GA57174@ast-mbp.thefacebook.com> <57D9D6FE.4090708@digikod.net>
 <20160914232418.GD60248@ast-mbp.thefacebook.com> <57DB11B6.7090500@digikod.net>
 <20160920001215.GA91808@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160920001215.GA91808@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm fine giving up the Checmate name. Landlock seems easy enough to
Google. I haven't gotten a chance to look through the entire patchset
yet, but it does seem like they are somewhat similar.

On Mon, Sep 19, 2016 at 5:12 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Sep 15, 2016 at 11:25:10PM +0200, Micka=C3=ABl Sala=C3=BCn wrote:
>> >> Agreed. With this RFC, the Checmate features (i.e. network helpers)
>> >> should be able to sit on top of Landlock.
>> >
>> > I think neither of them should be called fancy names for no technical =
reason.
>> > We will have only one bpf based lsm. That's it and it doesn't
>> > need an obscure name. Directory name can be security/bpf/..stuff.c
>>
>> I disagree on an LSM named "BPF". I first started with the "seccomp LSM"
>> name (first RFC) but I later realized that it is confusing because
>> seccomp is associated to its syscall and the underlying features. Same
>> thing goes for BPF. It is also artificially hard to grep on a name too
>> used in the kernel source tree.
>> Making an association between the generic eBPF mechanism and a security
>> centric approach (i.e. LSM) seems a bit reductive (for BPF). Moreover,
>> the seccomp interface [1] can still be used.
>
> agree with above.
>
>> Landlock is a nice name to depict a sandbox as an enclave (i.e. a
>> landlocked country/state). I want to keep this name, which is simple,
>> express the goal of Landlock nicely and is comparable to other sandbox
>> mechanisms as Seatbelt or Pledge.
>> Landlock should not be confused with the underlying eBPF implementation.
>> Landlock could use more than only eBPF in the future and eBPF could be
>> used in other LSM as well.
>
> there will not be two bpf based LSMs.
> Therefore unless you can convince Sargun to give up his 'checmate' name,
> nothing goes in.
> The features you both need are 90% the same, so they must be done
> as part of single LSM whatever you both agree to call it.
>
