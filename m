From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] bluetooth.h: __ variants of u8 and friends are not
 neccessary inside kernel
Date: Thu, 6 Oct 2016 09:41:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB01E3EAB@AcuExch.aculab.com>
References: <20161003085640.GA8130@amd>
         <368810F9-519C-44B5-85D4-1815273438BF@holtmann.org>
         <1475689996.6105.11.camel@perches.com> <20161005191103.GA25972@amd>
 <1475694934.1941.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Marcel Holtmann <marcel@holtmann.org>,
        "trivial@kernel.org" <trivial@kernel.org>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        "Johan Hedberg" <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Joe Perches' <joe@perches.com>, Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475694934.1941.1.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Of Joe Perches
...
> No worries, and bool is the same size as u8.

That is not guaranteed at all.
One of the ARM ABI defined bool to be the size of int.

	David
