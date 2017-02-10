From: Edward Cree <ecree@solarflare.com>
Subject: Re: sfc: process RX event inner checksum flags
Date: Fri, 10 Feb 2017 16:52:43 +0000
Message-ID: <053538d2-f641-47a4-fee4-5919f033cd39@solarflare.com>
References: <61213e24-db1d-8a56-e1a9-e68ae689b73f@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <61213e24-db1d-8a56-e1a9-e68ae689b73f@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/02/17 16:14, Colin Ian King wrote:
> Hi there,
>
>
> not sure if this is a bug, or intentional, but CoverityScan picked up a
> mismatch in arguments when calling efx_ef10_handle_rx_event_error() with
> commit "sfc: process RX event inner checksum flags"

It's a bug, thanks for the catch (and thanks Coverity as well).

Will send a patch shortly.

-Ed
