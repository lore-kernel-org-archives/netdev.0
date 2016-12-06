From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/2] misc: atmel-ssc: register as sound DAI if
 #sound-dai-cells is present
Date: Tue, 6 Dec 2016 09:16:35 -0600
Message-ID: <20161206151635.psckjlu2pyzjm7k6@rob-hp-laptop>
References: <1480593549-6464-1-git-send-email-peda@axentia.se>
 <1480593549-6464-2-git-send-email-peda@axentia.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 alsa-devel@alsa-project.org, Arnd Bergmann <arnd@arndb.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Takashi Iwai <tiwai@suse.com>,
 Nicolas Ferre <nicolas.ferre@atmel.com>, linux-kernel@vger.kernel.org,
 Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>,
 netdev@vger.kernel.org, Jaroslav Kysela <perex@perex.cz>,
 linux-arm-kernel@lists.infradead.org
To: Peter Rosin <peda@axentia.se>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1480593549-6464-2-git-send-email-peda@axentia.se>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 01, 2016 at 12:59:08PM +0100, Peter Rosin wrote:
> The SSC is currently not usable with the ASoC simple-audio-card, as
> every SSC audio user has to build a platform driver that may do as
> little as calling atmel_ssc_set_audio/atmel_ssc_put_audio (which
> allocates the SSC and registers a DAI with the ASoC subsystem).
> 
> So, have that happen automatically, if the #sound-dai-cells property
> is present in devicetree, which it has to be anyway for simple audio
> card to work.
> 
> Signed-off-by: Peter Rosin <peda@axentia.se>
> ---
>  .../devicetree/bindings/misc/atmel-ssc.txt         |  2 +

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/misc/atmel-ssc.c                           | 50 ++++++++++++++++++++++
>  include/linux/atmel-ssc.h                          |  1 +
>  3 files changed, 53 insertions(+)
