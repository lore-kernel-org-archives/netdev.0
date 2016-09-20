From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: lsm naming dilemma. Re: [RFC v3 07/22] landlock: Handle file
 comparisons
Date: Mon, 19 Sep 2016 17:12:16 -0700
Message-ID: <20160920001215.GA91808@ast-mbp.thefacebook.com>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net>
 <20160914210649.GA57174@ast-mbp.thefacebook.com>
 <57D9D6FE.4090708@digikod.net>
 <20160914232418.GD60248@ast-mbp.thefacebook.com>
 <57DB11B6.7090500@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-security-module-u79uwXL29Tb/PtFMR13I2A@public.gmane.org
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57DB11B6.7090500-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 15, 2016 at 11:25:10PM +0200, Mickaël Salaün wrote:
> >> Agreed. With this RFC, the Checmate features (i.e. network helpers)
> >> should be able to sit on top of Landlock.
> > 
> > I think neither of them should be called fancy names for no technical reason.
> > We will have only one bpf based lsm. That's it and it doesn't
> > need an obscure name. Directory name can be security/bpf/..stuff.c
> 
> I disagree on an LSM named "BPF". I first started with the "seccomp LSM"
> name (first RFC) but I later realized that it is confusing because
> seccomp is associated to its syscall and the underlying features. Same
> thing goes for BPF. It is also artificially hard to grep on a name too
> used in the kernel source tree.
> Making an association between the generic eBPF mechanism and a security
> centric approach (i.e. LSM) seems a bit reductive (for BPF). Moreover,
> the seccomp interface [1] can still be used.

agree with above.

> Landlock is a nice name to depict a sandbox as an enclave (i.e. a
> landlocked country/state). I want to keep this name, which is simple,
> express the goal of Landlock nicely and is comparable to other sandbox
> mechanisms as Seatbelt or Pledge.
> Landlock should not be confused with the underlying eBPF implementation.
> Landlock could use more than only eBPF in the future and eBPF could be
> used in other LSM as well.

there will not be two bpf based LSMs.
Therefore unless you can convince Sargun to give up his 'checmate' name,
nothing goes in.
The features you both need are 90% the same, so they must be done
as part of single LSM whatever you both agree to call it.
