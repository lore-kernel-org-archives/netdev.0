From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next v2 06/10] net: dsa: lan9303: added sysfs node
 swe_bcst_throt
Date: Thu, 27 Jul 2017 12:59:44 +0200
Message-ID: <f0105583-9363-e8a6-79fc-675bb8dbadcf@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-7-privat@egil-hjelmeland.no>
 <20170726171423.GQ12049@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170726171423.GQ12049@lunn.ch>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26. juli 2017 19:14, Andrew Lunn wrote:
> On Tue, Jul 25, 2017 at 06:15:49PM +0200, Egil Hjelmeland wrote:
>> Allowing per-port access to Switch Engine Broadcast Throttling Register
> 
> Hi Egil
> 
> In general, we are against using sysfs. If there is a generic
> mechanism, that applies for all sorts of network interfaces, it should
> be used instead of sysfs.
> 
> Is this intended to reduce the effect of broadcast storms?
> 
>     Andrew
> 

Yes, this setting can be used to reduce effect of broadcast storms.

I knew you all dislike using sysfs. Still I had a hope you could accept
the dsa_net_device_to_dsa_port() function it the previous patch.
I feel it would be convenient to be able to add driver sysfs nodes in
private branches for own debug and fine tuning, without having to patch
the networking core.



Egil
