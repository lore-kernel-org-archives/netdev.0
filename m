From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next-2.6 v6 1/1] can: c_can: Added support for Bosch
 C_CAN	controller
Date: Wed, 09 Feb 2011 11:41:30 +0100
Message-ID: <4D526F5A.6030706@grandegger.com>
References: <1297227821-18021-1-git-send-email-bhupesh.sharma@st.com> <4D525DF8.6050409@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bhupesh Sharma <bhupesh.sharma@st.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:54323 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203Ab1BIKjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 05:39:54 -0500
In-Reply-To: <4D525DF8.6050409@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marc,

On 02/09/2011 10:27 AM, Marc Kleine-Budde wrote:
> On 02/09/2011 06:03 AM, Bhupesh Sharma wrote:
>> +	if (flags & IF_ARB_TRANSMIT)
>> +		frame->can_id |= CAN_RTR_FLAG;
> 
> Can you please only copy the data to the frame if the rtr flag isn't
> set. Not all driver do this yet, but we've agreed to do so.

Yes, I remember the patch

[PATCH v2 0/9] can: don't copy data to rx'ed RTR frames

What happend with it?

Wolfgang.
