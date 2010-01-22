From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 02/13] net-caif: add CAIF header files
Date: Fri, 22 Jan 2010 10:43:28 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E07903232069@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com> <1264146719.3469.5.camel@violet> <61D8D34BB13CFE408D154529C120E07903231FED@eseldmw101.eemea.ericsson.se> <1264149542.3469.8.camel@violet> <61D8D34BB13CFE408D154529C120E07903232025@eseldmw101.eemea.ericsson.se> <1264151779.3469.14.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stefano.babic@babic.homelinux.org>, <randy.dunlap@oracle.com>
To: "Marcel Holtmann" <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:64943 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab0AVJnu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 04:43:50 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1264151779.3469.14.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann wrote:
> Hi Sjur,
> 
>>>> CAIFSO_CHANNEL is used for specifying the physical interface to use
>>>> for the CAIF Channel. You can select the type of interface to use
>>>> by setting link_selector: CAIF_PHYPREF_LOW_LAT will typically be
>>>> used for AT (or other control traffic), and CAIF_PHYPREF_HIGH_BW
>>>> for IP traffic.
>>>> When the CAIF interfaces registers itself it will inform about
>>>> their type, (low-latency or high-bandwidth). This approach assumes
>>>> that you have only one modem, but multiple links to it (e.g. USB
>>>> and UART). 
>>>> 
>>>> But you can also specify interface by name using link_name. In this
>>>> case you specify the name of the interface to use. I think this
>>>> would support your use case with multiple modems attached.
>>> 
>>> sounds good, but why using a socket option and not allowing to just
>>> use bind(). Maybe it is just my personal preference, because I am
>>> used to do it like this for TCP and Bluetooth.
>> 
>> We actually considered this when designing the interface, but I don't
>> feel bind() fits in this case. bind() would normally bind an address
>> to the client socket. An interface did not seem like a client socket
>> address to us, so we decided to use sockopt instead.
>> Conceptually I don't think CAIF has a client address at all, it only
>> connects to a server side address.
> 
> seems fair enough to me. My personal preference would just be bind,
> but I can follow your argumentation. I just wanted to make sure that
> we have that option before setting CAIF socket address in stone.  
> 
> Any reason why not just supporting SO_PRIORITY and SO_BINDTODEVICE on
> CAIF sockets then? 

Sounds like a good idea, I'll definitely look into that, thanks.

BR/Sjur
