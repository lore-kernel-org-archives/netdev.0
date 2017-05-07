From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: loop: Check for memory allocation failure
Date: Sun, 7 May 2017 16:22:44 -0700
Message-ID: <8a792a74-f1f1-59a0-df46-5f6c3861fa20@gmail.com>
References: <20170506052945.2639-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170506052945.2639-1-christophe.jaillet@wanadoo.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 05/05/17 à 22:29, Christophe JAILLET a écrit :
> If 'devm_kzalloc' fails, a NULL pointer will be dereferenced.
> Return -ENOMEM instead, as done for some other memory allocation just a
> few lines above.
> 
> Fixes: 98cd1552ea27 ("net: dsa: Mock-up driver")
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
