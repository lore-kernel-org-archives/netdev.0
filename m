From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: ethoc: enable NAPI before poll may be scheduled
Date: Tue, 6 Jun 2017 07:26:20 -0700
Message-ID: <ff6b545e-abdb-fca6-27bf-957d6a59cd62@gmail.com>
References: <1496712676-11862-1-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Thierry Reding <thierry.reding@gmail.com>,
        Tobias Klauser <tklauser@distanz.ch>, stable@vger.kernel.org
To: Max Filippov <jcmvbkbc@gmail.com>, netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1496712676-11862-1-git-send-email-jcmvbkbc@gmail.com>
Content-Language: en-US
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 06/05/2017 06:31 PM, Max Filippov wrote:
> ethoc_reset enables device interrupts, ethoc_interrupt may schedule a
> NAPI poll before NAPI is enabled in the ethoc_open, which results in
> device being unable to send or receive anything until it's closed and
> reopened. In case the device is flooded with ingress packets it may be
> unable to recover at all.
> Move napi_enable above ethoc_reset in the ethoc_open to fix that.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>

Fixes: a1702857724f ("net: Add support for the OpenCores 10/100 Mbps
Ethernet MAC.")

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
