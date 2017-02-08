From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH net-next v3 04/11] bpf: Use bpf_load_program() from the
 library
Date: Wed, 8 Feb 2017 17:41:10 -0200
Message-ID: <20170208194110.GB2162@redhat.com>
References: <20170207214500.27496-1-mic@digikod.net>
 <20170207214500.27496-5-mic@digikod.net>
 <589A5597.7090107@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53130 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751498AbdBHTl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 14:41:29 -0500
Content-Disposition: inline
In-Reply-To: <589A5597.7090107@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Feb 07, 2017 at 03:17:43PM -0800, Alexei Starovoitov escreveu:
> On 2/7/17 1:44 PM, Mickaël Salaün wrote:
> >-	union bpf_attr attr;
> >+	union bpf_attr attr = {};
> >
> >-	bzero(&attr, sizeof(attr));
 
> I think somebody mentioned that there are compilers out there
> that don't do it correctly, hence it was done with explicit bzero.
> Arnaldo, Wang, do you remember the details?

Yeah, lemme dig it...

- Arnaldo
