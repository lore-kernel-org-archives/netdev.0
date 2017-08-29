From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Permissions for eBPF objects
Date: Mon, 28 Aug 2017 18:15:47 -0700
Message-ID: <20170829011545.hjhpmyaerd44r5xo@ast-mbp>
References: <CABXk95AiYO7D8o79TBdt0_0g1TXfULSpL5i7KzHF3R4i-WhwHw@mail.gmail.com>
 <1503689199.9977.4.camel@tycho.nsa.gov>
 <CABXk95BkyU5MBLry0PEp+QwhtY7rM4DCmQq3CeQi6=TQtQQPwA@mail.gmail.com>
 <CAMOXUJkQ-Wh==9nzgx3Sq4RUEBK5ArHk4b=AL0N65L9g6cAqcg@mail.gmail.com>
 <59A0837F.9090301@iogearbox.net>
 <20170826010330.tuospq5h43fv3tlp@ast-mbp>
 <CAMOXUJ=kiZDEpuBfys0Me4o8wqSymCz+Eu_qdQdOH5+Czzfj8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jeffrey Vander Stoep <jeffv@google.com>,
        Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
To: Chenbo Feng <fengc@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34869 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbdH2BPu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 21:15:50 -0400
Received: by mail-pg0-f43.google.com with SMTP id 63so6249774pgc.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 18:15:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAMOXUJ=kiZDEpuBfys0Me4o8wqSymCz+Eu_qdQdOH5+Czzfj8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 05:47:19PM -0700, Chenbo Feng wrote:
> On Fri, Aug 25, 2017 at 6:03 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Fri, Aug 25, 2017 at 10:07:27PM +0200, Daniel Borkmann wrote:
> >> On 08/25/2017 09:52 PM, Chenbo Feng wrote:
> >> > On Fri, Aug 25, 2017 at 12:45 PM, Jeffrey Vander Stoep <jeffv@google.com> wrote:
> >> > > On Fri, Aug 25, 2017 at 12:26 PM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
> >> > > > On Fri, 2017-08-25 at 11:01 -0700, Jeffrey Vander Stoep via Selinux
> >> > > > wrote:
> >> > > > > I’d like to get your thoughts on adding LSM permission checks on BPF
> >> > > > > objects.
> >
> > before reinventing the wheel please take a look at landlock work.
> > Everything that was discussed in this thread is covered by it.
> > The patches have been in development for more than a year and most of the early
> > issues have been resolved.
> > It will be presented again during security summit in LA in September.
> >
> I am not very familiar with landlock lsm, isn't this module also
> depend on the lsm hooks to do
> the landlock check? If so then adding lsm hooks for eBPF object seems
> not conflict with the
> work on progress.

I see. I got it the other way around. What lsm checks are you proposing?
and why unprivileged_bpf_disabled is not enough?
you want to allow unpriv only for specific user(s) ?
