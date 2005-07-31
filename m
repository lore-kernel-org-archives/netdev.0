From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] drivers/net/8139too.c: rework the debug levels
Date: Sun, 31 Jul 2005 00:45:48 -0400
Message-ID: <42EC577C.8080407@pobox.com>
References: <20050722211309.GP3160@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261622AbVGaEpz@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050722211309.GP3160@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> Looking at this driver, I wondered why there were two different 
> #define's controlling the debug output of the driver.


Because debug output and runtime checks are two different concepts, two 
different behaviors.

	Jeff
