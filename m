From: Ohad Ben-Cohen <ohad@wizery.com>
Subject: Re: [PATCH 1/5] omap: panda: wlan board muxing
Date: Mon, 14 Feb 2011 09:24:30 +0200
Message-ID: <AANLkTik4+CRp8B8Ajnpy-_k1m+=MZNe62c2WG8cjaz-D@mail.gmail.com>
References: <1297667958-22377-1-git-send-email-panduranga_mallireddy@ti.com> <1297667958-22377-2-git-send-email-panduranga_mallireddy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: coelho@ti.com, netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-mmc@vger.kernel.org, benzyg@ti.com, pradeepgurumath@ti.com,
	vishalm@ti.com, x-boudet@ti.com, naveen_jain@ti.com,
	pavan_savoy@ti.com, manjunatha_halli@ti.com, tony@atomide.com,
	cjb@laptop.org
To: panduranga_mallireddy@ti.com
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1297667958-22377-2-git-send-email-panduranga_mallireddy@ti.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pandu,

On Mon, Feb 14, 2011 at 9:19 AM,  <panduranga_mallireddy@ti.com> wrote:
> + =A0 =A0 =A0 /* WLAN IRQ - GPIO 53 */
> + =A0 =A0 =A0 OMAP4_MUX(GPMC_NCS3, OMAP_MUX_MODE3 | OMAP_PIN_INPUT_PU=
LLUP),

Actually we don't need to pull up the IRQ line -  it is always held by
the 1271 device, and there's no need for the host to pull it up
(wasting some power while doing it).

We have that on the ZOOM, but that's not necessary, and will be fixed
there, too.

Thanks,
Ohad.
