From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] natsemi: Use round_jiffies() for slow timers
Date: Tue, 09 Oct 2007 20:47:08 -0400
Message-ID: <470C210C.6030800@pobox.com>
References: <1191967059-7143-1-git-send-email-broonie@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: thockin@hockin.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753492AbXJJAr0@vger.kernel.org>
In-Reply-To: <1191967059-7143-1-git-send-email-broonie@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown wrote:
> Unless we have failed to fill the RX ring the timer used by the natsemi
> driver is not particularly urgent and can use round_jiffies() to allow
> grouping with other timers.
> 
> Signed-off-by: Mark Brown <broonie@sirena.org.uk>
> ---
>  drivers/net/natsemi.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)

ACK but does not apply to netdev-2.6.git#upstream or davem/net-2.6.24.git
