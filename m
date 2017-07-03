From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/17] v3 net generic subsystem refcount conversions
Date: Mon, 03 Jul 2017 03:30:17 -0700
Message-ID: <1499077817.1462.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1498817290-3368-1-git-send-email-elena.reshetova@intel.com>
         <1499074136.1462.0.camel@edumazet-glaptop3.roam.corp.google.com>
         <2236FBA76BA1254E88B949DDB74E612B6FF2029D@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "bridge@lists.linux-foundation.org"
        <bridge@lists.linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "keescook@chromium.org" <keescook@chromium.org>
To: "Reshetova, Elena" <elena.reshetova@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612B6FF2029D@IRSMSX102.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-07-03 at 09:57 +0000, Reshetova, Elena wrote:

> Thank you very much for the report! This is an underflow (dec/sub from
> zero) that is reported by WARNING. 
> I guess it is unlikely that actual code underflows, so the most
> probable cause is that it attempted to do refcount_inc/add() from
> zero, but then failed. 
> However  in that case you should have seen another warning on
> refcount_inc() somewhere earlier. That one is actually the one I need
> to see to track the root cause. 
> Could you tell me how do you arrive to the below output? Boot in what
> config/etc. 
> I can try to reproduce to debug further. 

I sent this fix : 

https://patchwork.ozlabs.org/patch/783389/

Thanks.
