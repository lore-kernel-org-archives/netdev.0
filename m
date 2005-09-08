From: Bogdan Costescu <Bogdan.Costescu@iwr.uni-heidelberg.de>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Thu, 8 Sep 2005 15:35:26 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0509081521140.21354@dingo.iwr.uni-heidelberg.de>
References: <200509080125.j881PcL9015847@hera.kernel.org>  <431F9899.4060602@pobox.com>
  <Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de>
 <1126184700.4805.32.camel@tsc-6.cph.tpack.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751356AbVIHNfl@vger.kernel.org>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <1126184700.4805.32.camel@tsc-6.cph.tpack.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Sep 2005, Tommy Christensen wrote:

> The idea is to avoid an extra delay of 60 seconds before detecting 
> link-up.

But you are adding the read to a function that is called repeatedly to 
fix an event that happens only once at start-up !

If this read is really needed (I still doubt it...), can't it be 
performed in vortex_up(), by possibly doubling the existing one there ?
vortex_up() is executed only once at start-up, not every 60 seconds.

> Please see http://bugzilla.kernel.org/show_bug.cgi?id=5025

Hah, a Cisco switch.  Look in Documentation/networking/vortex.txt for 
"portfast".

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
