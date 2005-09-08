From: Bogdan Costescu <Bogdan.Costescu@iwr.uni-heidelberg.de>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Thu, 8 Sep 2005 13:58:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de>
References: <200509080125.j881PcL9015847@hera.kernel.org> <431F9899.4060602@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751317AbVIHL6W@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <431F9899.4060602@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Sep 2005, Jeff Garzik wrote:

>> The phy status register must be read twice in order to get the actual link
>> state.

Can the original poster give an explanation ? I've enjoyed a rather 
well functioning 3c59x driver for the past ~6 years without such 
double reading. Plus:
- this operation is I/O expensive
- it is performed inside a region protected by a spinlock
- it is performed often, every 60 seconds

Is there some specific hardware that exhibits a problem that is solved 
by this double reading ?

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
