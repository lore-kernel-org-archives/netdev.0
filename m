From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next PATCH v1 00/11] A flow API
Date: Mon, 5 Jan 2015 18:42:48 -0800
Message-ID: <CAE4R7bAERNhK55zAcwtzEoay_oWvzk74KOc4aN=TLMxSg8Eaag@mail.gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46054 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbbAFCmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 21:42:49 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so4501668wiw.1
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 18:42:48 -0800 (PST)
In-Reply-To: <20141231194057.31070.5244.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 11:45 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> Finally I have more patches to add support for creating and destroying
> tables. This allows users to define the pipeline at runtime rather
> than statically as rocker does now. After this set gets some traction
> I'll look at pushing them in a next round. However it likely requires
> adding another "world" to rocker.

Yes, it would require another "world" to be added to rocker.  It would
be cool if someone could work on this.  Currently, the only world
rocker supports is OF-DPA, which is based on Broadcom's published
OF-DPA spec.  OF-DPA is a fixed pipeline with predefined tables.  I'd
like to see a "universal machine" world added to rocker that presents
a programmable pipeline and programmable tables.  The nice thing is
most of the rocker device and driver code gets reused fro this new
world.  Nothing changes about the port interface, or the DMA/MSI/PCI
interfaces, or the I/O, cmd, and event paths, so much is reused.

> Another piece that I want to add is
> a description of the actions and metadata. This way user space can
> "learn" what an action is and how metadata interacts with the system.
> This work is under development.
