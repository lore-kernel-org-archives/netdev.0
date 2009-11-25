From: =?ISO-8859-1?Q?Fran=E7ois?= Delawarde
	<fdelawarde@wirelessmundi.com>
Subject: netfilter hooks for IFB device
Date: Wed, 25 Nov 2009 16:30:20 +0100
Message-ID: <1259163020.28137.141.camel@luna.tc.commsmundi.com>
Reply-To: fdelawarde@wirelessmundi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.wirelessmundi.com ([91.121.102.180]:57496 "EHLO
	mail.wirelessmundi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557AbZKYP7r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 10:59:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm interested in adding optional netfilter hooks to the IFB device
(enabled by module param), in order to have full IMQ functionality (to
use CONNMARKs and others) without having to add any iptables or
netfilter target.

I'm aiming for something very simple inspired by this older IMQ
implementation:
http://pupa.da.ru/imq/imq.c

The only thing is, I have no idea what to do in the callback function
once the netfilter hooks are registered.

How can I 'steal' the packet in the hook and make it pass through
ifb_xmit to have it enqueued?

Thanks,
=46ran=C3=A7ois.

