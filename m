From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 02/13] net-caif: add CAIF header files
Date: Fri, 22 Jan 2010 11:53:16 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E079032320D3@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com> <4B5805D1.3000803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<marcel@holtmann.org>, <stefano.babic@babic.homelinux.org>,
	<randy.dunlap@oracle.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:55114 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab0AVKyX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 05:54:23 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B5805D1.3000803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick.

Patrick McHardy wrote:
> sjur.brandeland@stericsson.com wrote:
>> +/**
>> + * enum ifla_caif
>> + * When using RT Netlink to create, destroy or configure a CAIF IP
>> +interface, + * enum ifla_caif is used to specify the configuration
>> attributes. + * + * @IFLA_CAIF_IPV4_CONNID:  Connection ID for IPv4
>> PDP Context. + *			    The type of attribute is NLA_U32.
>> + * @IFLA_CAIF_IPV6_CONNID:  Connection ID for IPv6 PDP Context.
>> + *			    The type of attribute is NLA_U32.
>> + * @IFLA_CAIF_LOOPBACK:	    If different from zero, device is doing
>> loopback + *			    The type of attribute is NLA_U8.
>> + */
>> +enum ifla_caif {
>> +	IFLA_CAIF_IPV4_CONNID,
>> +	IFLA_CAIF_IPV6_CONNID,
>> +	IFLA_CAIF_LOOPBACK,
>> +	__IFLA_CAIF_MAX
>> +};
>> +#define	IFLA_CAIF_MAX (__IFLA_CAIF_MAX-1)
>> +
>> +#endif /*IF_CAIF_H_*/
> 
> You should add an IFLA_CAIF_UNSPEC at the beginning, some of the
> nlattr helpers skip attributes with a value of zero. 

OK, thanks. I'll fix this in the next patch set.

BR/Sjur
