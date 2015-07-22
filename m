From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2] tc: fix bpf compilation with old glibc
Date: Wed, 22 Jul 2015 09:47:02 -0700
Message-ID: <20150722094702.2eb3c0ea@urahara>
References: <1437568170-16995-1-git-send-email-nicolas.dichtel@6wind.com>
	<19c76849dd1f4a94875b0aa5d3d7e96c@HQ1WP-EXMB12.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:45323 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934322AbbGVQrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 12:47:11 -0400
In-Reply-To: <19c76849dd1f4a94875b0aa5d3d7e96c@HQ1WP-EXMB12.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jul 2015 13:05:32 +0000
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 07/22/2015 02:29 PM, Nicolas Dichtel wrote:
> > Error was:
> > f_bpf.o: In function `bpf_parse_opt':
> > f_bpf.c:(.text+0x88f): undefined reference to `secure_getenv'
> > m_bpf.o: In function `parse_bpf':
> > m_bpf.c:(.text+0x587): undefined reference to `secure_getenv'
> > collect2: error: ld returned 1 exit status
> >
> > CC: Daniel Borkmann <daniel@iogearbox.net>
> > Fixes: 88eea5395483 ("tc: {f,m}_bpf: allow to retrieve uds path from env")
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Thanks Nicolas! I am thinking we should probably just stick to getenv()
> and convert these two users.
> 
> Thanks,
> Daniel

Yes, please use getenv() unless there is a obvious special
security requirement involved. 
