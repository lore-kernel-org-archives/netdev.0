From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ethernet: renesas: sh_eth: do not access POST
 registers if not exist
Date: Sun, 28 Aug 2016 21:31:01 +0300
Message-ID: <9f2fd410-f521-4ae1-92ed-572aa84cee46@cogentembedded.com>
References: <20160826200107.20681-1-chris.brandt@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Daniel Palmer <daniel@0x0f.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Chris Brandt <chris.brandt@renesas.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160826200107.20681-1-chris.brandt@renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

    Oh, and I'll have to correct your language and terminology. :-/
Should be "if they don't exist" in the subject.

On 08/26/2016 11:01 PM, Chris Brandt wrote:

> The RZ/A1 has a TSU, but since it only has one Ethernet port, it does not
> have POST registers. Therefore, if you try to write to register index
> TSU_POST1 (which will be FFFF because it does not exist),

    It's not a register index which is 0xFFFF but the register offset (fetched 
from a layout table using the index).

> it will either panic or corrupt memory elsewhere.
>
> Reported-by: Daniel Palmer <daniel@0x0f.com>
> Signed-off-by: Chris Brandt <chris.brandt@renesas.com>
[...]

MBR, Sergei
