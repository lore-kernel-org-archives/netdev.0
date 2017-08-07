From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: lan9303: Only allocate 3 ports
Date: Mon, 7 Aug 2017 15:27:25 -0700
Message-ID: <99b1379c-3af4-c09d-1f86-041da58f615b@gmail.com>
References: <20170807222221.28963-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807222221.28963-1-privat@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/07/2017 03:22 PM, Egil Hjelmeland wrote:
> Save 2628 bytes on arm eabi by allocate only the required 3 ports.
> 
> Now that ds->num_ports is correct: In net/dsa/tag_lan9303.c
> eliminate duplicate LAN9303_MAX_PORTS, use ds->num_ports.
> (Matching the pattern of other net/dsa/tag_xxx.c files.)
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
