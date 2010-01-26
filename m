From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 10/13] net-caif: add kernel-client API for CAIF
Date: Tue, 26 Jan 2010 20:56:09 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E0790326AE5F@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com><1264028130-14364-11-git-send-email-sjur.brandeland@stericsson.com> <20100126095054.bd20673a.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<marcel@holtmann.org>, <stefano.babic@babic.homelinux.org>
To: "Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw-virt-test.ericsson.se ([193.180.251.35]:55060 "EHLO
	mailgw-virt-test.ericsson.se" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750799Ab0AZULO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 15:11:14 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20100126095054.bd20673a.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Randy,

Randy Dunlap wrote:
> On Wed, 20 Jan 2010 23:55:27 +0100 sjur.brandeland@stericsson.com
> 
> Hi,
> 
> I'm probably repeating myself here, but this function documentation
> is not formatted in the way which the Linux kernel expects/wants. 
> 
> Some of the others (after this one) use "/**" to begin the comment
> block. 
> In kernel-land, that is used only for kernel-doc formatted notation.

Thanks for feedback, it is rather my fault letting this slip through.
As you probably have figured CAIF was originally documented using
doxygen for formatting. Unfortunately I have not yet managed to get rid of this.

> 
> 
>> +/*!\page  caif_kernel.h
>> + * This is the specification of the CAIF kernel internal interface
>> to + * CAIF Channels. + * This interface follows the pattern used in
>> Linux device drivers +with a + *  struct \ref caif_device
>> + * holding control data handling each device instance. + *
>> + * The functional interface consists of a few basic functions:
>> + *  - \ref caif_add_device             Configure and connect the
>> CAIF + *               channel to the remote end. Configuration is
>> described in + *               \ref caif_channel_config.
>> + *  - \ref caif_remove_device          Disconnect and remove the
>> channel. + *  - \ref caif_transmit               Sends a CAIF
>> message on the link. + *  - \ref caif_device.receive_cb      Receive
>> callback function for + *                receiving packets.
>> + *  - \ref caif_device.control_cb      Control information from the
>> CAIF stack. + *  - \ref caif_flow_control           Send flow
>> control message to remote end. + * + *
>> + * Details:
>> + * \see { caif_kernel }
>> + *
>> + * \code
>> + *
>> +#include <net/caif/caif_kernel.h>"

BR/Sjur
