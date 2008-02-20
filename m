From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: add kdump support
Date: Wed, 20 Feb 2008 11:50:42 -0500
Message-ID: <47BC5A62.2030701@garzik.org>
References: <47B30A49.8080404@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48779 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751AbYBTQus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 11:50:48 -0500
In-Reply-To: <47B30A49.8080404@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Klein wrote:
> This patch adds kdump support to the ehea driver. As the firmware doesn't free
> resource handles automatically, the driver has to run an as simple as possible
> free resource function in case of a crash shutdown. The function iterates over
> two arrays freeing all resource handles which are stored there. The arrays are
> kept up-to-date during normal runtime. The crash handler fn is triggered by the
> recently introduced PPC crash shutdown reg/unreg functions.
> 
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> 
> ---
>  drivers/net/ehea/ehea.h      |   34 +++++-
>  drivers/net/ehea/ehea_main.c |  281 ++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 290 insertions(+), 25 deletions(-)

applied


