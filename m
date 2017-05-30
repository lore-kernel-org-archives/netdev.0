From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 4/6] net: dsa: remove unused arguments of
 tagger rcv
Date: Tue, 30 May 2017 12:59:23 -0700
Message-ID: <a01d88e5-5bb2-dd83-e416-daa6ebe0fb66@gmail.com>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
 <20170530183319.10718-5-vivien.didelot@savoirfairelinux.com>
 <b31811c6-d019-da1f-9df0-0ad00264204b@gmail.com>
 <87shjmyv9m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87shjmyv9m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/30/2017 12:55 PM, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> I actually have a patch pending that adds support for HW
>> insertion/extraction of switch tags (broadcom HW supports that) which
>> require the orig_dev to be there so we know what features are supported
>> by the master network device.
> 
> Is orig_dev really needed in the tagging implementation, or only in the
> layer above? (dsa_slave_xmit and dsa_switch_rcv.)

It's needed:

https://github.com/ffainelli/linux/commits/switch-tag
https://github.com/ffainelli/linux/commit/61f9ca70dd21bb8c1615f959934cd0ce80a2f3ce

> 
>> Do you mind dropping this one from your patch series?
> 
> I don't mind if they are actually needed in taggers. I'd wait for
> reviews of the other patches before respinning though.
> 
> Thanks,
> 
>         Vivien
> 


-- 
Florian
