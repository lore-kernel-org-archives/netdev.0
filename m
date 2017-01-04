From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-next 0/6] Prepare BPF for VLAN_TAG_PRESENT cleanup
Date: Wed, 4 Jan 2017 22:30:24 +0100
Message-ID: <20170104213024.sghqhqfbzqfl4z47@rere.qmqm.pl>
References: <cover.1483492355.git.mirq-linux@rere.qmqm.pl>
 <586D570D.9060800@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:52984 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757559AbdADVkR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 16:40:17 -0500
Content-Disposition: inline
In-Reply-To: <586D570D.9060800@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 09:11:57PM +0100, Daniel Borkmann wrote:
> On 01/04/2017 02:18 AM, Micha³ Miros³aw wrote:
> > Those patches prepare BPF ant its JITs for removal of VLAN_TAG_PRESENT.
> > The set depends on "Preparation for VLAN_TAG_PRESENT cleanup" patchset.
> > 
> > The series is supposed to be bisect-friendly and that requires temporary
> > insertion of #define VLAN_TAG_PRESENT in BPF code to be able to split
> > JIT changes per architecture.
> > 
> > Micha³ Miros³aw (6):
> >    net/skbuff: add macros for VLAN_PRESENT bit
> >    net/bpf_jit: ARM: split VLAN_PRESENT bit handling from VLAN_TCI
> >    net/bpf_jit: MIPS: split VLAN_PRESENT bit handling from VLAN_TCI
> >    net/bpf_jit: PPC: split VLAN_PRESENT bit handling from VLAN_TCI
> >    net/bpf_jit: SPARC: split VLAN_PRESENT bit handling from VLAN_TCI
> >    net/bpf: split VLAN_PRESENT bit handling from VLAN_TCI
> 
> Please add a proper changelog to all the individual patches, right now
> they have none. Also, how was this runtime tested? Did you run BPF selftest
> suite with them? Seems like they weren't even compile tested properly
> given the kbuild bot barking on sparc ...

Compile bot is barking because it doesn't have patches, which this set depends on.
Sorry about that.

Best Regards,
Micha³ Miros³aw
