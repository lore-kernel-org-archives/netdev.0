From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH RFC 1/3] net: bridge: log state when setting it
Date: Sat, 13 Feb 2016 16:49:45 -0500
Message-ID: <87egcgl1qe.fsf@ketchup.mtl.sfl>
References: <1455312860-24666-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1455312860-24666-2-git-send-email-vivien.didelot@savoirfairelinux.com> <20160213200353.GA17193@colbert.idosch.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43694 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbcBMVts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 16:49:48 -0500
In-Reply-To: <20160213200353.GA17193@colbert.idosch.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ido,

Ido Schimmel <idosch@mellanox.com> writes:

> Fri, Feb 12, 2016 at 11:34:18PM IST, vivien.didelot@savoirfairelinux.com wrote:
>
> Hi Vivien,
>
>>Every call to br_set_state is followed by a call to br_log_state.
>>Directly call it within br_set_state instead.
>>
>>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>>---
>
> Maybe I'm missing something, but there are other instances of this
> pattern throughout the code, so why not convert them as well? See
> br_set_port_state() for example.

Good catch, I'll factorize that and send this as a unique patch then.

Thanks,
-v
