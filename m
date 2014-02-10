From: Bo Shen <voice.shen@atmel.com>
Subject: [PATCH v3 0/2] ASoC: atmel_ssc_dai: add option to
	choose clock
Date: Mon, 10 Feb 2014 14:09:44 +0800
Message-ID: <1392012586-30790-1-git-send-email-voice.shen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, alsa-devel@alsa-project.org,
 Stephen Warren <swarren@wwwdotorg.org>, linux-doc@vger.kernel.org,
 Takashi Iwai <tiwai@suse.de>, nicolas.ferre@atmel.com,
 Bo Shen <voice.shen@atmel.com>, Chas Williams <chas@cmf.nrl.navy.mil>,
 Lars-Peter Clausen <lars@metafoo.de>, Pawel Moll <pawel.moll@arm.com>,
 linux-atm-general@lists.sourceforge.net, plagnioj@jcrosoft.com,
 devicetree@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>, linux-sound@vger.kernel.org,
 Rob Herring <rob.herring@calxeda.com>, linux-arm-kernel@lists.infradead.org,
 Richard Genoud <richard.genoud@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Liam Girdwood <lgirdwood@gmail.com>, linux-kernel@vger.kernel.org,
 Rob Landley <rob@landley.net>, netdev@vger.kernel.org,
 Mark Brown <broonie@linaro.org>
To: broonie@kernel.org
Return-path: <alsa-devel-bounces@alsa-project.org>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

When SSC work in slave mode, the clock can come from TK pin and also
can come from RK pin, this is hardware design decided. So, make it
available to choose where the clock from.

Changes in v3:
  - Move the property from card to ssc device
Series-changes: 2
  - using "-" replace "_" in binding document

Bo Shen (2):
  ASoC: atmel_ssc_dai: make option to choose clock
  Binding: atmel-ssc: add option to choose clock

 Documentation/devicetree/bindings/misc/atmel-ssc.txt |  8 ++++++++
 drivers/misc/atmel-ssc.c                             |  6 ++++++
 include/linux/atmel-ssc.h                            |  1 +
 sound/soc/atmel/atmel_ssc_dai.c                      | 13 +++++++++----
 4 files changed, 24 insertions(+), 4 deletions(-)

-- 
1.8.5.2
