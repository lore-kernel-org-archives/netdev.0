From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the
 permisions of netlink messages
Date: Thu, 8 May 2014 15:07:12 -0700
Message-ID: <20140508150712.35e41e66@nehalam.linuxnetplumber.net>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
	<536AB151.2070804@dti2.net>
	<CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
	<20140507.185256.496391962242529591.davem@davemloft.net>
	<CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
	<CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
	<20140508142939.201b3e07@nehalam.linuxnetplumber.net>
	<CA+55aFzOHZcw2o6Cq6rSddSBDZvhgzYToBruak9SLCHxx-fA3Q@mail.gmail.com>
	<CALCETrWP_u+9Aw1Hf-7JWECP5mX55rUAp4bKRJf16jjo=0-+0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"security@kernel.org" <security@kernel.org>,
	Vivek Goyal <vgoyal@redhat.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Simo Sorce <ssorce@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Network Development <netdev@vger.kernel.org>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	David Miller <davem@davemloft.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:44913 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755378AbaEHWHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 18:07:16 -0400
Received: by mail-pd0-f172.google.com with SMTP id g10so2814282pdj.31
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 15:07:15 -0700 (PDT)
In-Reply-To: <CALCETrWP_u+9Aw1Hf-7JWECP5mX55rUAp4bKRJf16jjo=0-+0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 May 2014 14:49:11 -0700
Andy Lutomirski <luto@amacapital.net> wrote:

> TBH, I'm starting to think that the real solution is to add a new syscall:
> 
> sys_net_ctl(int nl_proto, const void *intput, size_t inlen, void
> *output, size_t outlen)

No.
Changing all the applications based on netlink is a really bad idea.
