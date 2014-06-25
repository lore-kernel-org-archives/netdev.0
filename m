From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: [PATCH 05/17] MIPS: bpf: Return error code if the offset is a
 negative number
Date: Wed, 25 Jun 2014 09:12:53 +0100
Message-ID: <53AA8485.4040805@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>	<1403516340-22997-6-git-send-email-markos.chandras@imgtec.com> <CAMEtUuyL8EV3UxS7yaD_ufiAywr7hkgPSC-3etMEYfbAZ_rRew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux MIPS Mailing List <linux-mips@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Network Development" <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:28859 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755052AbaFYIM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 04:12:56 -0400
In-Reply-To: <CAMEtUuyL8EV3UxS7yaD_ufiAywr7hkgPSC-3etMEYfbAZ_rRew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2014 11:09 PM, Alexei Starovoitov wrote:
> On Mon, Jun 23, 2014 at 2:38 AM, Markos Chandras
> <markos.chandras@imgtec.com> wrote:
>> Previously, the negative offset was not checked leading to failures
>> due to trying to load data beyond the skb struct boundaries. Until we
>> have proper asm helpers in place, it's best if we return ENOSUPP if K
>> is negative when trying to JIT the filter or 0 during runtime if we
>> do an indirect load where the value of X is unknown during build time.
>>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Alexei Starovoitov <ast@plumgrid.com>
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
> 
> Hi Markos,
> 
> thank you for addressing all of my earlier comments.
> Looks like test_bpf was quite useful in finding all of these bugs :)
> For the patches that reached netdev:
> 
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> 

Thank you for the review and your constructive comments in your previous
emails.

-- 
markos
