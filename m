From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: Be able to set bss expire time at config
 stage.
Date: Mon, 22 May 2017 18:34:02 +0200
Message-ID: <1495470842.26008.4.camel@sipsolutions.net>
References: <20170522160946.2057-1-enric.balletbo@collabora.com>
         <1495469954.26008.1.camel@sipsolutions.net>
         (sfid-20170522_182014_038071_64240E1B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Dmitry Shmidt <dimitrysh@google.com>,
        helmut.schaa@googlemail.com
To: Enric Balletbo i Serra <enric.balletbo@collabora.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1495469954.26008.1.camel@sipsolutions.net> (sfid-20170522_182014_038071_64240E1B)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-05-22 at 18:19 +0200, Johannes Berg wrote:
> 
> I'm not really all that convinced that we really need this -
> userspace should just be using the flush thing more often, and then
> it doesn't really matter.
> 
> However, maybe that doesn't really matter all that much.

Actually, I changed my mind based on the discussion with Dan. This
makes no sense, and since you've obviously never even tested this
patch, you probably haven't thought about alternatives either.

johannes
