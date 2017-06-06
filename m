From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] net: ethoc: enable NAPI before poll may be scheduled
Date: Tue, 6 Jun 2017 08:05:05 +0200
Message-ID: <20170606060504.GB16486@distanz.ch>
References: <1496712676-11862-1-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Thierry Reding <thierry.reding@gmail.com>,
        stable@vger.kernel.org
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1496712676-11862-1-git-send-email-jcmvbkbc@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-06-06 at 03:31:16 +0200, Max Filippov <jcmvbkbc@gmail.com> wrote:
> ethoc_reset enables device interrupts, ethoc_interrupt may schedule a
> NAPI poll before NAPI is enabled in the ethoc_open, which results in
> device being unable to send or receive anything until it's closed and
> reopened. In case the device is flooded with ingress packets it may be
> unable to recover at all.
> Move napi_enable above ethoc_reset in the ethoc_open to fix that.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
