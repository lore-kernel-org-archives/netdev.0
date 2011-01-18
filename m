From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Tue, 18 Jan 2011 11:08:42 +0800
Message-ID: <AANLkTi=YU-JeKFtD6iDEuH+JsK2EHmGnq3ehXfy+-AA8@mail.gmail.com>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com> <1295288462.3335.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com, bhutchings@solarflare.com,
	joe@perches.com, dilinger@queued.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295288462.3335.55.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Eric,

On Tue, Jan 18, 2011 at 2:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> BTW, shouldnt you use cpu_to_be32() or cpu_to_le32(), if this driver is
> multi platform ?

This reminds me another thing. Should I use u32 instead of unsigned int for all
hardware related variables (registers, descriptors) ?
Not quite sure about these cross-platform issues.

best regards,
Po-Yu Chuang
