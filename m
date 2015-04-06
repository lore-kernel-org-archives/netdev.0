From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC PATCH 5/5] geneve: add initial netdev driver for GENEVE tunnels
Date: Mon, 6 Apr 2015 15:52:09 -0700
Message-ID: <CAEP_g=9vO0BiBVq93UJguz_g4WhYzHFfn4oqOug_kGOkQ6MZow@mail.gmail.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
 <CAEP_g=9PbDO4qK-GaGosBAq1S5C5uWNR4-JN8=i158oYJUN4Bw@mail.gmail.com> <20150406184300.GB2866@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:55996 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751264AbbDFWwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 18:52:32 -0400
Received: by mail-la0-f47.google.com with SMTP id t2so22502678laa.1
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 15:52:30 -0700 (PDT)
In-Reply-To: <20150406184300.GB2866@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 6, 2015 at 11:43 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> On Fri, Apr 03, 2015 at 02:05:20PM -0700, Jesse Gross wrote:
>> I also wanted to mention that Geneve (the protocol, not the current
>> implementation) can encapsulate protocols other than Ethernet, similar
>> to GRE. I don't think this is necessary for a first implementation but
>> it's worth keeping in mind in case there is anything that we end up
>> designing in the interfaces that can keep this clean in the future.
>
> Yeah, good point.  Do you think that would be specified at
> tunnel setup?  What sort of flexibility will it require?

Yes, I would expect that it is specified at tunnel setup time since it
will affect the type of netdevice that is created. I don't think that
it needs to be tremendously flexible as most networks will carry
either Ethernet or IP and use that as the next protocol (although
there could be other interesting use cases like specifying that the
payload is encrypted).
