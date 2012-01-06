From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] drivers: misc: Remove MISC_DEVICES config option
Date: Thu, 5 Jan 2012 23:13:55 -0200
Message-ID: <CAOMZO5ADu=FAzB7s9cK2LMcWb8JqupjfV6wDEcGu_kfGT93nyQ@mail.gmail.com>
References: <1325796541-11402-1-git-send-email-festevam@gmail.com>
	<4F0635FE.6050507@xenotime.net>
	<4F063B75.8020207@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	gwingerde@gmail.com, davem@davemloft.net,
	bhutchings@solarflare.com, greg@kroah.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F063B75.8020207@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 5, 2012 at 10:08 PM, Larry Finger <Larry.Finger@lwfinger.ne=
t> wrote:
> Fabio,
>
> Does this patch fix your problem?

It will fix this specific EEPROM_93CX6 issue, but I recall seeing
other similar cases of build warnings related to the missing
dependency of MISC_DEVICES. I can=C2=B4t provide any other examples unt=
il
Tuesday next week.

Instead of fixing each instance where this MISC_DEPENDENCY issue
happens, I think that removing MISC_DEVICES could be a good fix.

Regards,

=46abio Estevam
