From: Marc Zyngier <maz@misterjones.org>
Subject: Re: [PATCH] [resend] 3c509: convert to isa_driver and pnp_driver v3
Date: Thu, 07 Feb 2008 12:51:11 +0100
Message-ID: <wrphcglx9w0.fsf@hina.wild-wind.fr.eu.org>
References: <200801312012.43447.linux@rainbow-software.org>
	<200802021925.36552.linux@rainbow-software.org>
	<47A4D791.3050700@garzik.org>
	<200802061909.37452.linux@rainbow-software.org>
Reply-To: maz@misterjones.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757188AbYBGMHU@vger.kernel.org>
In-Reply-To: <200802061909.37452.linux@rainbow-software.org> (Ondrej Zary's
	message of "Wed, 6 Feb 2008 19:09:35 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Ondrej" == Ondrej Zary <linux@rainbow-software.org> writes:

Ondrej> Tested using 3 ISA cards in various combinations of PnP and non-PnP modes.

Ondrej>  #ifdef CONFIG_EISA
Ondrej>  	ret = eisa_driver_register(&el3_eisa_driver);
Ondrej> +	if (!ret)
Ondrej> +		eisa_registeted = 1;
Ondrej>  #endif
                        ^^^^^^^^^^^^^^^

You probably should at least test-compile this driver with CONFIG_EISA
enabled...

Regards,

	M.
-- 
And if you don't know where you're going, any road will take you there...
