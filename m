From: Marc Zyngier <mzyngier@freesurf.fr>
Subject: Re: 2.6.4-rc1 + hp100 EISA, not working
Date: Mon, 01 Mar 2004 11:12:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wrpptbwyiyx.fsf@hina.wild-wind.fr.eu.org>
References: <Pine.LNX.4.58.0402292149230.25624@don.falconne.eu.org>
Reply-To: mzyngier@freesurf.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pawel.sokolowski@muflon.linux.pl
In-Reply-To: <Pine.LNX.4.58.0402292149230.25624@don.falconne.eu.org> (Pawe's
 message of "Sun, 29 Feb 2004 22:06:16 +0100 (CET)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Pawel" == Pawe  <Pawe> writes:

Pawel> I don't know if it's related to this problem but at earlier stage of
Pawel> booting I'm getting following messages:

Pawel> EISA: Probing bus 0 at eisa0
Pawel> EISA: Mainboard HWPC061 detected.
Pawel> EISA: slot 2 : HWP1940 detected (disabled).
Pawel> EISA: Detected 1 card.

Try passing 'eisa_bus.enable_dev=2' to your kernel parameters. Your
card is tagged as unconfigured by BIOS, and thus is skipped by the
probing logic. See Documentation/eisa.txt for details.

	M.
-- 
Places change, faces change. Life is so very strange.
