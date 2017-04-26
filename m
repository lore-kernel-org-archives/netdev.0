From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [oss-drivers] Re: [RFC 3/4] nfp: make use of extended ack message
 reporting
Date: Wed, 26 Apr 2017 15:31:58 +0200
Message-ID: <5900A14E.1030008@iogearbox.net>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com> <20170425080644.122536-4-jakub.kicinski@netronome.com> <9765d004-de19-7cf2-fcfc-1d2e72cded43@mojatatu.com> <20170425.102022.219410555949403896.davem@davemloft.net> <20170426111315.GC28251@vergenet.net> <646e0fb0-1f10-f4d0-936c-7fdf96b6cc43@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        johannes@sipsolutions.net, dsa@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl, oss-drivers@netronome.com
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53886 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1955326AbdDZNcH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:32:07 -0400
In-Reply-To: <646e0fb0-1f10-f4d0-936c-7fdf96b6cc43@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2017 03:03 PM, Jamal Hadi Salim wrote:
> On 17-04-26 07:13 AM, Simon Horman wrote:
>
>> I don't feel strongly about this and perhaps it can be revisited at some
>> point but perhaps it would be worth documenting that he strings do not
>> form part of the UAPI as my expectation would have been that they do f.e. to
>> facilitate internationalisation.
>
> I thought people script against what iproute2 outputs today. We
> may have to change habits.

I would strictly treat this kind of auxiliary information as
non-stable error message data, and it should be documented
as such, f.e. in the man page.

Every driver or subsystem using this could have different
restrictions/semantics and thus error messages will not be
the same everywhere anyway, so there's zero point in parsing
this text from an application in the first place, it's just
passing this through to the user to aide debugging.
