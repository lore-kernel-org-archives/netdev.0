From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH V2 1/4] can: m_can: update to support CAN FD features
Date: Wed, 5 Nov 2014 19:36:08 +0800
Message-ID: <20141105113607.GD4007@shlinux1.ap.freescale.net>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com>
 <545A0B6F.8060706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-can@vger.kernel.org>, <mkl@pengutronix.de>,
	<wg@grandegger.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <linux-arm-kernel@lists.infradead.org>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <545A0B6F.8060706@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 05, 2014 at 05:05:11PM +0530, Varka Bhadram wrote:
> Hi Dong Aisheng,
> 
> On 11/05/2014 01:28 PM, Dong Aisheng wrote:
> 
> >Bosch M_CAN is CAN FD capable device. This patch implements the CAN
> >FD features include up to 64 bytes payload and bitrate switch function.
> >1) Change the Rx FIFO and Tx Buffer to 64 bytes for support CAN FD
> >    up to 64 bytes payload. It's backward compatible with old 8 bytes
> >    normal CAN frame.
> >2) Allocate can frame or canfd frame based on EDL bit
> >3) Bitrate Switch function is disabled by default and will be enabled
> >    according to CANFD_BRS bit in cf->flags.
> >
> >Signed-off-by: Dong Aisheng <b29396@freescale.com>
> 
> In these four patches two of them are V1 and other two are V2.
> 
> Is there any reason..?
> 

Sorry for confusion.
Because some patches are already picked by Macr on the first round.
See below:
http://www.spinics.net/lists/netdev/msg302133.html

> How will you be able to generate like this by git format-patch..?
> 

Generated as v2 and i manually changed the later two to v1 since they
are new.
Not sure if it's suitable to do like that. :-)

Regards
Dong Aisheng

> -- 
> Thanks and Regards,
> Varka Bhadram.
> 
